import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/models/get_clip_info_model.dart';
import 'package:gaanap_admin_new/models/get_game_data_model.dart';
import 'package:gaanap_admin_new/models/user/user_model.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/services/session_controller/session_controller.dart';
import 'package:gaanap_admin_new/utils/Utils.dart';
import 'package:gaanap_admin_new/utils/enums.dart';
import 'package:gaanap_admin_new/views/gamebegain/widgets/graph.dart';
import 'package:gaanap_admin_new/views/gamebegain/widgets/textthumbshape.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../../bloc/event/event_bloc.dart';
import '../../config/app_url.dart';
import '../../main.dart';
import '../../services/storage/local_storage.dart';

class GameScreen extends StatefulWidget {
  final String gameid;
  final String hostid;
  const GameScreen({Key? key,
  required this.gameid,
  required this.hostid}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late EventBloc _eventBloc;
  late FirebaseDatabase db1;
  late DatabaseReference dbref;
  var fireData;
  GetGameDataModel gameDataModel = GetGameDataModel();
  Clip currentClip = Clip();
  int currentClipScore = 0;
  UserModel userModel = UserModel();

  double current = 0; // Start from 20 seconds
  Timer? timer;
  Color sliderColor = AppColors.timerInitial;
  bool isPaused = false;

  int selectedOption = 0;
  bool performAnswer = false;


  bool showResult = false;
  bool showScore = false;

  int clipScore = 0;
  int totalUserScore = 0;
  int totalScore = 0;
  int currentClipScoreEarn = 0;
  String answerPerform = "wrong";
  String name = '';

  List<int> playerValues = [];

  int totalPlayers = 0;
  int currentRanking = 0;
  bool showRanking = false;

  final AudioPlayer _player = AudioPlayer();
  late StreamSubscription<DatabaseEvent> dbSub;
  LocalStorage localStorage = LocalStorage();

  Option? correctAnswerOb = Option();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // WakelockPlus.enable();

    getGameData();
    db1 = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppUrl.firebaseUrl,
    );
    dbref = db1.ref(AppUrl.fireDatabaseName);
    _eventBloc = EventBloc(eventRepository: getit());
    fireDataManage();


    // playAudio();



  }

  fireDataManage() async {
    await localStorage.addData("game_status", "gameStart");

    getGameData();

    userModel = await SessionController().userModel;
    dbSub = dbref.onValue.listen((event) {
      final data = event.snapshot.value;
      fireData = data;
      debugPrint("🔥 REALTIME DATA: $data");
      if (fireData != null) {
        var clipscreen = fireData["globalClipScreenChange"];
        var globalShowCumulativeScore = fireData["globalShowCumulativeScore"];
        var globalClipScoreboard = fireData["globalClipScoreboard"];
        var globalFinalScoreboard = fireData["globalFinalScoreboard"];
        Map<String, dynamic> scoreMap = {};
        String globalClipScoreboardClipId = '';

        if (globalClipScoreboard != null) {
          final dynamic data = fireData["globalClipScoreboard"]?["data"];

          debugPrint("Score 11");

          final rawData = globalClipScoreboard["data"];

          if (rawData is Map) {
            debugPrint("Score 22");
            final firstEntry = data.values.first;
            if (firstEntry is Map) {
              globalClipScoreboardClipId = firstEntry["clip_id"].toString();
            }

            scoreMap = Map<String, dynamic>.from(rawData);
          }
          else if (rawData is List) {
            debugPrint("Score 33");

            for (int i = 0; i < rawData.length; i++) {
              final item = rawData[i];
              if (item != null && item is Map) {
                scoreMap[i.toString()] = item;
              }
            }
            debugPrint("Score ${scoreMap}");
            for (final item in data) {
              if (item is Map && item["clip_id"] != null) {
                globalClipScoreboardClipId = item["clip_id"].toString();
                break;
              }
            }
          }
        }


        if (clipscreen != null) {
          showRanking = false;
          showScore = false;
          // answerPerform = "wrong";
          if (globalFinalScoreboard != null &&
              globalFinalScoreboard['data'] != null) {
            dbSub.cancel();
            Navigator.of(context).pushNamedAndRemoveUntil(
              RoutesName.finalScorecard, (route) => false,
              arguments: {
                "game_id": fireData["gameActivated"]["game_id"].toString(),
                "host_id": fireData["gameActivated"]["host_id"].toString(),
              },);
          }

          else if (scoreMap.isNotEmpty &&
              clipscreen["data"]["clip_id"].toString().contains(
                  globalClipScoreboardClipId.toString())) {
            calculatePlayersAndRanking(
                scoreMap, clipscreen['data']['clip_id'].toString());
            debugPrint("ranking 00");

            if (globalShowCumulativeScore != null) {
              debugPrint("ranking 11");


              if (clipscreen['data']['clip_id'].toString().contains(
                  globalShowCumulativeScore['data']["current_clip_id"]
                      .toString())) {
                showRanking = true;
                setState(() {

                });
              }
            }
          }

          else if (fireData["currentClipScore"] != null &&
              clipscreen["data"]["clip_id"] ==
                  fireData["currentClipScore"]["data"]["clip_id"]) {

            currentClip = gameDataModel.clips!.firstWhere(
                  (element) =>
              element.clipId.toString() ==
                  clipscreen["data"]["clip_id"].toString(),
              orElse: () => Clip(), // use your empty model
            );


            getOptionResultForGraph();
          }
          else {
            performAnswer = false;
            selectedOption = 0;
            isPaused = false;
            showResult = false;
            showScore = false;
            answerPerform = "wrong";
            getCurrentClip(clipscreen["data"]["clip_id"]);
          }

          // context.read<EventBloc>().add(GetClipInfoEvent(clip_id: clipscreen["data"]["clip_id"].toString()));
        }
        else {
          if (fireData['gameActivated'] == null) {
            _player.stop();
            dbSub.cancel();
            logout(context);
          }
        }
      }
    });
  }

  void calculatePlayersAndRanking(Map<String, dynamic> scoreMap,
      String currentClipID) {
    if (scoreMap.isEmpty) return;
    String clipid = '';

    /// 1️⃣ Convert entries to list
    final List<Map<String, dynamic>> players = [];

    for (final entry in scoreMap.values) {
      if (entry is Map) {
        players.add(Map<String, dynamic>.from(entry));
      }
    }

    /// 2️⃣ Total players count
    totalPlayers = players.length;

    /// 3️⃣ Sort players by totalScore (DESC)
    players.sort((a, b) {
      final scoreA = (a["totalScore"] ?? 0) as int;
      final scoreB = (b["totalScore"] ?? 0) as int;
      return scoreB.compareTo(scoreA); // high → low
    });

    /// 4️⃣ Find current user's ranking
    currentRanking = 0;

    for (int i = 0; i < players.length; i++) {
      final userId = players[i]["user_id"];
      currentClipScoreEarn = players[i]['clipScore'];
      totalUserScore = players[i]['totalScore'];
      name = players[i]["full_name"];

      clipid = players[i]['clip_id'].toString();
      if (userId.toString() == userModel.user?.id.toString()) {
        currentRanking = i + 1; // rank starts from 1

        break;
      }
    }

    debugPrint("Total Players = $totalPlayers");
    debugPrint("Current Ranking = $currentRanking");
    debugPrint("Show Score :: ${clipid ==
        currentClipID} :: ${currentClipID} :: ${clipid}  :: ${showScore}");
    if (clipid == currentClipID) {
      // Iterable<Option>? option = currentClip.options?.where((option) {
      //   return option.clipCorrectOption.toString().contains("C");
      // });
      // correctAnswerOb = option?.first;
      // debugPrint("correctAnswerOb >> ${correctAnswerOb?.toJson()}");
      if (mounted) {
        setState(() {
          showScore = true;

        });
      }
      debugPrint("Show Score :: ${clipid ==
          currentClipID} :: ${currentClipID} :: ${clipid}  :: ${showScore}");
    }

  }


  getCurrentClip(int clipid) {
    currentClip = gameDataModel.clips!.firstWhere(
          (element) => element.clipId.toString() == clipid.toString(),
      orElse: () => Clip(), // use your empty model
    );

    String level = currentClip.clipLevel ?? ""; // example: "Ga"
    Score score = gameDataModel.score!;


    switch (level) {
      case "Sa":
        currentClipScore = score.sa ?? 0;
        break;
      case "Re":
        currentClipScore = score.re ?? 0;
        break;
      case "Ga":
        currentClipScore = score.ga ?? 0;
        break;
      case "Ma":
        currentClipScore = score.ma ?? 0;
        break;
      case "Pa":
        currentClipScore = score.pa ?? 0;
        break;
    }
    totalScore += currentClipScore;
    current = currentClip.timerLength?.toDouble() ?? 0;
    // startTimer();
    setState(() {

    });
    startTimer();
    playAudio("${AppUrl.clipBAseUrl}/${currentClip.clipFileName}");
  }

  getGameData() async {
    var map = await LocalStorage.readModel("get_game_data");
    if (map != null) {
      gameDataModel = GetGameDataModel.fromJson(map);
    }
  }

  Future<void> playAudio(String url) async {
    if (gameDataModel.gameSound?.toLowerCase().contains("off") ?? false) return;
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {}
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isPaused && current > 0) {
        setState(() {
          current--;

          // Color changing logic
          if (current <= 7) {
            sliderColor = AppColors.timerLast;
          } else if (current <= 14) {
            sliderColor = AppColors.timerMid;
          } else {
            sliderColor = AppColors.timerInitial;
          }
        });
      } else {
        t.cancel();
      }
    });
  }


  void pauseTimer() {
    _player.pause();
    setState(() {
      isPaused = true;
      // resultTimer();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    timer?.cancel();
    dbSub.cancel(); // 🔥 stops Firebase stream
    super.dispose();
  }

  submitAnswer(String answerId, String answer) {

    int clipTimer = currentClip.timerLength ?? 0;
    var responseTime = clipTimer - current;
    int clipScore = currentClipScore;

    var score = (1 - responseTime / clipTimer / 2) * clipScore;

    // currentClipScoreEarn = answer.contains("C") ? score.toInt() : 0;
    answerPerform = answer.contains("C") ? "right" : "wrong";
    context.read<EventBloc>().add(SubmitClipAnswerEvent(
        host_id: widget.hostid,
        game_id: widget.gameid,
        clip_id: currentClip.clipId.toString() ?? "",
        is_demo_clip: currentClip.isDemoClip.toString() ?? "",
        response_time: responseTime.toString(),
        user_id: userModel.user?.id.toString() ?? "",
        answer_id: answerId,
        score: answer.contains("C") ? score.toString() : "0"
    ));
  }

  void getOptionResultForGraph() {
    if (fireData == null) return;

    final scoreData = fireData["currentClipScore"]?["data"];
    if (scoreData is! Map) return;

    final Map<String, dynamic> scoreMap =
    Map<String, dynamic>.from(scoreData);

    /// options list from your currentClip JSON
    final List<Option> options = currentClip.options ?? [];

    /// clear previous values
    playerValues = [];

    for (var option in options) {
      final optionId = option.id.toString(); // 36165, 36161...

      /// match firebase key with option.id
      final value = scoreMap[optionId] ?? 0;

      playerValues.add(value);
    }

    showResult = true;
    showScore = false;
    // answerPerform = "wrong";
    _player.pause();

    if (mounted) {
      setState(() {});
    }

    debugPrint("Ordered Player Values: $playerValues");
  }

  @override
  Widget build(BuildContext context) {
    return
      showScore
          ? showScoreScreen()
          : Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.6),
          backgroundColor: Colors.white,
          title: Text("HFMGame", style: TextStyle(
              fontWeight: FontWeight.w500
          ),),
          actions: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.lightestGrey
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: EdgeInsets.only(right: 10),
              child: Text(
                "${currentClip.clipOrderNo ?? 0}/${(gameDataModel.clips
                    ?.length ?? 0) - 1}",
                style: TextStyle(
                    color: Colors.black
                ),),
            )
          ],
          leading: IconButton(onPressed: () {
            logout(context);
          },
              icon: Icon(Icons.logout)),
        ),
        body: BlocListener<EventBloc, EventState>(
          listener: (context, state) {

          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child:

            Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 150,
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage(
                              currentClip.clipLevel?.toLowerCase().contains(
                                  "sa") ?? false
                                  ? AppImages.saRectLeft
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("re") ?? false
                                  ? AppImages.reRectLeft
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ga") ?? false
                                  ? AppImages.gaRectLeft
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ma") ?? false
                                  ? AppImages.maRectLeft
                                  : AppImages.paRectLeft

                          ),
                            fit: BoxFit.fill, // fills the container
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Level - ",
                            style: TextStyle(
                                color: AppColors.saTextColor,
                                fontSize: 18
                            ),),
                          Image.asset(AppImages.sa,
                              height: 20),
                          const SizedBox(width: 5),
                          Text("${currentClip.clipLevel ?? ""}",
                            style: TextStyle(
                                color: AppColors.saTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18

                            ),)
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 30,
                      width: 120,
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage(
                              currentClip.clipLevel?.toLowerCase().contains(
                                  "sa") ?? false
                                  ? AppImages.saRectRight
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("re") ?? false
                                  ? AppImages.reRectRight
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ga") ?? false
                                  ? AppImages.gaRectRight
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ma") ?? false
                                  ? AppImages.maRectRight
                                  : AppImages.paRectRight
                          ),
                            fit: BoxFit.fill, // fills the container
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                              currentClip.clipLevel?.toLowerCase().contains(
                                  "sa") ?? false
                                  ? AppImages.saStar
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("re") ?? false
                                  ? AppImages.reStar
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ga") ?? false
                                  ? AppImages.gaStar
                                  : currentClip.clipLevel
                                  ?.toLowerCase()
                                  .contains("ma") ?? false
                                  ? AppImages.maStar
                                  : AppImages.paStar
                          ),
                          const SizedBox(width: 10,),
                          Text("${currentClipScore}",
                            style: TextStyle(
                                color: AppColors.saTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18

                            ),)
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 30,),
                Text(
                  "Do you recognize the song? \n Click on your answer below.",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                  ),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IgnorePointer(
                            ignoring: performAnswer,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: performAnswer
                                  ? (selectedOption == 1 || (showResult &&
                                  (currentClip.options?[0].clipCorrectOption
                                      .toString().contains("C") ?? false))
                                  ? 1.0 : 0.4) // fade others
                                  : 1.0,
                              child: InkWell(
                                onTap: () {
                                  if (showResult) return;
                                  selectedOption = 1;
                                  performAnswer = true;

                                  // pauseTimer();
                                  submitAnswer(
                                      currentClip.options?[0].id.toString() ??
                                          "",
                                      currentClip.options?[0].clipCorrectOption
                                          .toString() ?? "");
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * .2,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * .4,
                                        decoration: BoxDecoration(
                                            color: AppColors.op1Color,
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            border: Border.all(
                                                width: performAnswer &&
                                                    (((currentClip.options?[0]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                        &&
                                                        selectedOption == 1) ||
                                                        ((currentClip
                                                            .options?[0]
                                                            .clipCorrectOption
                                                            .toString()
                                                            .contains("C") ??
                                                            false)))
                                                    ? 4 : 0,
                                                color: showResult &&
                                                    (currentClip.options?[0]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("C") ?? false)
                                                    ? AppColors.rightAnswerColor
                                                    : showResult &&
                                                    performAnswer &&
                                                    selectedOption == 1 &&
                                                    (currentClip.options?[0]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                    ? AppColors.wrongAnswerColor
                                                    : !showResult &&
                                                    performAnswer
                                                    ? AppColors.grey
                                                    : Colors.white
                                            )
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Image.asset(
                                                  AppImages.Option1Icon,
                                                  height: 20,
                                                  width: 20,)),
                                            const SizedBox(height: 15,),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "${currentClip.options?[0]
                                                      .clipOptionDesc
                                                      .toString()}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    showResult && performAnswer &&
                                        selectedOption == 1 &&
                                        (currentClip.options?[0]
                                            .clipCorrectOption
                                            .toString()
                                            .contains("W") ?? false) ?
                                    Image.asset(AppImages.wrong,
                                      width: 30,
                                      height: 30,) : Container(),

                                    showResult && (currentClip.options?[0]
                                        .clipCorrectOption
                                        .toString()
                                        .contains("C") ?? false) ?
                                    Image.asset(AppImages.right,
                                      width: 30,
                                      height: 30,) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          IgnorePointer(
                            ignoring: performAnswer,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: performAnswer
                                  ? (selectedOption == 2 || (showResult &&
                                  (currentClip.options?[1].clipCorrectOption
                                      .toString().contains("C") ?? false))
                                  ? 1.0 : 0.4) // fade others
                                  : 1.0,
                              child: InkWell(
                                onTap: () {
                                  if (showResult) return;

                                  selectedOption = 2;
                                  performAnswer = true;

                                  // pauseTimer();
                                  submitAnswer(
                                      currentClip.options?[1].id.toString() ??
                                          "",
                                      currentClip.options?[1].clipCorrectOption
                                          .toString() ?? "");
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * .2,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * .4,
                                        decoration: BoxDecoration(
                                            color: AppColors.op2Color,
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            border: Border.all(
                                                width: performAnswer &&
                                                    (((currentClip.options?[1]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                        &&
                                                        selectedOption == 2) ||
                                                        ((currentClip
                                                            .options?[1]
                                                            .clipCorrectOption
                                                            .toString()
                                                            .contains("C") ??
                                                            false)))
                                                    ? 4 : 0,
                                                color: showResult &&
                                                    (currentClip.options?[1]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("C") ?? false)
                                                    ? AppColors.rightAnswerColor
                                                    : showResult &&
                                                    performAnswer &&
                                                    selectedOption == 2 &&
                                                    (currentClip.options?[1]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                    ? AppColors.wrongAnswerColor
                                                    : !showResult &&
                                                    performAnswer
                                                    ? AppColors.grey
                                                    : Colors.white
                                            )

                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Image.asset(
                                                  AppImages.Option2Icon,
                                                  height: 20,
                                                  width: 20,)),
                                            const SizedBox(height: 15,),

                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "${currentClip.options?[1]
                                                      .clipOptionDesc
                                                      .toString()}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    showResult && performAnswer &&
                                        selectedOption == 2 &&
                                        (currentClip.options?[1]
                                            .clipCorrectOption
                                            .toString()
                                            .contains("W") ?? false) ?
                                    Image.asset(AppImages.wrong,
                                      width: 30,
                                      height: 30,) : Container(),

                                    showResult && (currentClip.options?[1]
                                        .clipCorrectOption
                                        .toString()
                                        .contains("C") ?? false) ?
                                    Image.asset(AppImages.right,
                                      width: 30,
                                      height: 30,) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ),


                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IgnorePointer(
                            ignoring: performAnswer,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: performAnswer
                                  ? (selectedOption == 3 || (showResult &&
                                  (currentClip.options?[2].clipCorrectOption
                                      .toString().contains("C") ?? false))
                                  ? 1.0 : 0.4) // fade others
                                  : 1.0,
                              child: InkWell(
                                onTap: () {
                                  if (showResult) return;

                                  selectedOption = 3;
                                  performAnswer = true;

                                  // pauseTimer();
                                  submitAnswer(
                                      currentClip.options?[2].id.toString() ??
                                          "",
                                      currentClip.options?[2].clipCorrectOption
                                          .toString() ?? "");
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * .2,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * .4,
                                        decoration: BoxDecoration(
                                            color: AppColors.op3Color,
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            border: Border.all(
                                                width: performAnswer &&
                                                    (((currentClip.options?[2]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                        &&
                                                        selectedOption == 3) ||
                                                        ((currentClip
                                                            .options?[2]
                                                            .clipCorrectOption
                                                            .toString()
                                                            .contains("C") ??
                                                            false)))
                                                    ? 4 : 0,
                                                color: showResult &&
                                                    (currentClip.options?[2]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("C") ?? false)
                                                    ? AppColors.rightAnswerColor
                                                    : showResult &&
                                                    performAnswer &&
                                                    selectedOption == 3 &&
                                                    (currentClip.options?[2]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                    ? AppColors.wrongAnswerColor
                                                    : !showResult &&
                                                    performAnswer
                                                    ? AppColors.grey
                                                    : Colors.white
                                            )

                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Image.asset(
                                                  AppImages.Option3Icon,
                                                  height: 20,
                                                  width: 20,)),
                                            const SizedBox(height: 15,),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "${currentClip.options?[2]
                                                      .clipOptionDesc
                                                      .toString()}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    showResult && performAnswer &&
                                        selectedOption == 3 &&
                                        (currentClip.options?[2]
                                            .clipCorrectOption
                                            .toString()
                                            .contains("W") ?? false) ?
                                    Image.asset(AppImages.wrong,
                                      width: 30,
                                      height: 30,) : Container(),

                                    showResult && (currentClip.options?[2]
                                        .clipCorrectOption
                                        .toString()
                                        .contains("C") ?? false) ?
                                    Image.asset(AppImages.right,
                                      width: 30,
                                      height: 30,) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          IgnorePointer(
                            ignoring: performAnswer,
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: performAnswer
                                  ? (selectedOption == 4 || (showResult &&
                                  (currentClip.options?[3].clipCorrectOption
                                      .toString().contains("C") ?? false))
                                  ? 1.0 : 0.4) // fade others
                                  : 1.0,
                              child: InkWell(
                                onTap: () {
                                  if (showResult) return;

                                  selectedOption = 4;
                                  performAnswer = true;

                                  // pauseTimer();
                                  submitAnswer(
                                      currentClip.options?[3].id.toString() ??
                                          "",
                                      currentClip.options?[3].clipCorrectOption
                                          .toString() ?? "");
                                },
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,

                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * .2,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width * .4,
                                        decoration: BoxDecoration(
                                            color: AppColors.op4Color,
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            border: Border.all(
                                                width: performAnswer &&
                                                    (((currentClip.options?[3]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                        &&
                                                        selectedOption == 4) ||
                                                        ((currentClip
                                                            .options?[3]
                                                            .clipCorrectOption
                                                            .toString()
                                                            .contains("C") ??
                                                            false)))
                                                    ? 4 : 0,
                                                color: showResult &&
                                                    (currentClip.options?[3]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("C") ?? false)
                                                    ? AppColors.rightAnswerColor
                                                    : showResult &&
                                                    performAnswer &&
                                                    selectedOption == 4 &&
                                                    (currentClip.options?[3]
                                                        .clipCorrectOption
                                                        .toString()
                                                        .contains("W") ?? false)
                                                    ? AppColors.wrongAnswerColor
                                                    : !showResult &&
                                                    performAnswer
                                                    ? AppColors.grey
                                                    : Colors.white
                                            )

                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          children: [
                                            Align(
                                                alignment: Alignment.topLeft,
                                                child: Image.asset(
                                                  AppImages.Option4Icon,
                                                  height: 20,
                                                  width: 20,)),
                                            const SizedBox(height: 15,),

                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "${currentClip.options?[3]
                                                      .clipOptionDesc
                                                      .toString()}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    showResult && performAnswer &&
                                        selectedOption == 4 &&
                                        (currentClip.options?[3]
                                            .clipCorrectOption
                                            .toString()
                                            .contains("W") ?? false) ?
                                    Image.asset(AppImages.wrong,
                                      width: 30,
                                      height: 30,) : Container(),

                                    showResult && (currentClip.options?[3]
                                        .clipCorrectOption
                                        .toString()
                                        .contains("C") ?? false) ?
                                    Image.asset(AppImages.right,
                                      width: 30,
                                      height: 30,) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ),


                        ],
                      ),

                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child:
                      showResult
                          ? FourBarGraph(playerValues: playerValues,)
                          :
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          disabledActiveTrackColor: sliderColor,
                          disabledInactiveTrackColor: Colors.grey.shade300,
                          disabledThumbColor: sliderColor,
                          thumbColor: sliderColor,

                          overlayColor: sliderColor.withOpacity(0.3),
                          trackHeight: 10,
                          // Bigger slider


                          // Bigger thumb + text inside
                          thumbShape: TextThumbShape(
                            thumbRadius: 18, // Bigger thumb
                            text: current.toInt().toString(),
                          ),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                            min: 0,
                            max: 20,
                            value: current,

                            onChanged: null
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      );
  }

/*
  showScoreScreen(){
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: answerPerform == "wrong"
              ? AppColors.scoreWrongColor
              : null,
          image:
          answerPerform == 'wrong'
              ? null // ❌ hide image
              : DecorationImage(
              image: AssetImage(AppImages.scorecardBg,),
              fit: BoxFit.fill
          ),
        ),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            answerPerform == 'wrong'
            ?Container()
           :
            Image.asset(AppImages.star),
            const SizedBox(height: 20),
            Text(
              "${answerPerform == 'right' ? "Awesome" : "Sorry!"}, ${name.toUpperCase()}",
              style: GoogleFonts.roboto(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            Text(
              "${answerPerform == 'wrong' ? "That is not the right answer!" : "You got the right answer!"}",
              style: GoogleFonts.roboto(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You added ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Colors.white,

                    ),
                  ),
                  TextSpan(
                    text: "+${currentClipScoreEarn} ",
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: AppColors.darkPrimaryColor,

                    ),
                  ),
                  TextSpan(
                    text: "and your \n Total score is now ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Colors.white,

                    ),
                  ),
                  TextSpan(
                    text: "${totalUserScore} ",
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: AppColors.darkPrimaryColor,

                    ),
                  ),


                ],
              ),
            ),

            const SizedBox(height: 50),
            Visibility(
              visible: showRanking,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "And you are now number \n ",
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: Colors.white,

                      ),
                    ),
                    TextSpan(
                      text: "${currentRanking}",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color:  AppColors.darkPrimaryColor,

                      ),
                    ),
                    TextSpan(
                      text: " out of ",
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: Colors.white,

                      ),
                    ),
                    TextSpan(
                      text: "${totalPlayers} ",
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: AppColors.darkPrimaryColor,

                      ),
                    ),

                    TextSpan(
                      text: "players",
                      style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: Colors.white,

                      ),
                    ),


                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
              ),
              margin: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Song Name:",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                        softWrap: true,),
                      Expanded(
                        child: Text("${correctAnswerOb?.clipOptionDesc ?? ""}",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Text("Year:",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.start,
                        softWrap: true,),
                      Expanded(
                        child: Text("1971",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Text("Singer",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,),
                      Expanded(
                        child: Text("Asha Bhosle",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Text("Composer:",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,),
                      Expanded(
                        child: Text("O. P. Narayan",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,),
                      ),

                    ],
                  ),
                  Row(
                    children: [
                      Text("Lyricist",
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,),
                      Expanded(
                        child: Text("S.H. Bihari",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,),
                      ),

                    ],
                  ),

                ],
              ),
            )




          ],
        ),
      ),
    );
  }
*/


  Widget showScoreScreen() {
    final size = MediaQuery
        .of(context)
        .size;
    final bool isWrong = answerPerform == 'wrong';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- TOP RESULT BANNER ----------
              Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isWrong
                        ? [
                      AppColors.scoreWrongColor,
                      AppColors.scoreWrongColor.withOpacity(0.85),
                    ]
                        : [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Result icon: cross for wrong, star for right
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.25),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: isWrong
                            ? Icon(
                            Icons.close, color: AppColors.scoreWrongColor,
                            size: 40)
                            : Image.asset(
                            AppImages.star, width: 40, height: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${isWrong ? "Oops!" : "Awesome"}\n${name.toUpperCase()}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isWrong
                          ? "That is not the right answer!"
                          : "You got the right answer!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- SCORE CARD (two columns) ----------
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _ScoreColumn(
                                  icon: Icons.add_circle,
                                  iconColor: AppColors.darkPrimaryColor,
                                  iconBackground: AppColors.darkPrimaryColor
                                      .withOpacity(0.12),
                                  label: "You added",
                                  value: "+${currentClipScoreEarn}",
                                  caption: "to your score",
                                ),
                              ),
                              const VerticalDivider(width: 1, thickness: 1),
                              Expanded(
                                child: _ScoreColumn(
                                  icon: Icons.star,
                                  iconColor: AppColors.scoreWrongColor,
                                  iconBackground: AppColors.scoreWrongColor
                                      .withOpacity(0.12),
                                  label: "Total score",
                                  value: "${totalUserScore}",
                                  caption: "points",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ---------- RANK CARD ----------
                      Visibility(
                        visible: showRanking,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.scoreWrongColor.withOpacity(
                                  0.06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.scoreWrongColor
                                        .withOpacity(0.12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.emoji_events,
                                      color: AppColors.scoreWrongColor,
                                      size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Current Rank",
                                      style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      "${currentRanking}",
                                      style: GoogleFonts.roboto(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.scoreWrongColor,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      "out of ${totalPlayers} players",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ---------- SONG DETAILS CARD ----------
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondaryColor
                              .withOpacity(0.4), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SONG DETAILS",
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.scoreWrongColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(label: "Song Name",
                                value: "${currentClip.songName}"),
                            const Divider(height: 24),
                             _DetailRow(label: "Movie Name",
                                value: "${currentClip.ClipMovieName}"),
                            const Divider(height: 24),
                            _DetailRow(label: "Year", value: "${currentClip.ClipYear}"),
                            const Divider(height: 24),
                            _DetailRow(label: "Singer", value: "${currentClip.ClipSinger}"),
                            const Divider(height: 24),
                            _DetailRow(
                                label: "Composer", value: "${currentClip.ClipComposer}"),
                            const Divider(height: 24),
                            _DetailRow(label: "Lyricist", value: "${currentClip.ClipLyricist}"),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ScoreColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final String caption;

  const _ScoreColumn({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconBackground),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold, color: iconColor),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: GoogleFonts.roboto(fontSize: 13, color: AppColors.grey),
        ),
      ],
    );
  }
}

/// Reusable label/value row used in the Song Details card.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}


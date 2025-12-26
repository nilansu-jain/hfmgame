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
  GetGameDataModel gameDataModel= GetGameDataModel();
  Clip currentClip = Clip();
  int currentClipScore= 0;
  UserModel userModel= UserModel();
  
  double current = 0; // Start from 20 seconds
  Timer? timer;
  Color sliderColor = AppColors.timerInitial;
  bool isPaused = false;

  int selectedOption =0;
  bool performAnswer = false;

  
  bool showResult = false;
  bool showScore= false;

  int clipScore= 0;
  int totalUserScore =0;
  int totalScore =0;
  int currentClipScoreEarn= 0;
  String answerPerform = "";
  String name='';

  List<int> playerValues = [];

  int totalPlayers=0;
  int currentRanking =0;
  bool showRanking= false;

  final AudioPlayer _player = AudioPlayer();
  late StreamSubscription<DatabaseEvent> dbSub;
  LocalStorage localStorage = LocalStorage();

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
    _eventBloc= EventBloc(eventRepository: getit());
    fireDataManage();
    

    // playAudio();



  }

  fireDataManage() async{
    await localStorage.addData("game_status", "gameStart");

    getGameData();

    userModel= await SessionController().userModel;
    dbSub = dbref.onValue.listen((event) {
      final data = event.snapshot.value;
      fireData=data;
      debugPrint("🔥 REALTIME DATA: $data");
      if(fireData != null){

        var clipscreen = fireData["globalClipScreenChange"];
        var globalShowCumulativeScore = fireData["globalShowCumulativeScore"];
        var globalClipScoreboard = fireData["globalClipScoreboard"];
        var globalFinalScoreboard = fireData["globalFinalScoreboard"];
        Map<String, dynamic> scoreMap = {};
        String globalClipScoreboardClipId='';

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


        if(clipscreen != null){
          showRanking=false;
          showScore = false;
          if(globalFinalScoreboard != null && globalFinalScoreboard['data'] != null){
            dbSub.cancel();
            Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.finalScorecard, (route) => false,
              arguments: {
                "game_id": fireData["gameActivated"]["game_id"].toString(),
                "host_id": fireData["gameActivated"]["host_id"].toString(),
              },);

          }

          else if (scoreMap.isNotEmpty && clipscreen["data"]["clip_id"].toString().contains(globalClipScoreboardClipId.toString())) {

            calculatePlayersAndRanking(scoreMap,clipscreen['data']['clip_id'].toString());
            debugPrint("ranking 00");

            if(globalShowCumulativeScore != null){
              debugPrint("ranking 11");


              if(clipscreen['data']['clip_id'].toString().contains(globalShowCumulativeScore['data']["current_clip_id"].toString())){
                showRanking= true;
                setState(() {

                });
              }
            }

          }
          else if(fireData["currentClipScore"] != null && clipscreen["data"]["clip_id"] == fireData["currentClipScore"]["data"]["clip_id"]){
            currentClip = gameDataModel.clips!.firstWhere(
                  (element) => element.clipId.toString() == clipscreen["data"]["clip_id"].toString(),
              orElse: () => Clip(),  // use your empty model
            );


            getOptionResultForGraph();

          }
          else{

            performAnswer= false;
            selectedOption =0;
            isPaused = false;
            showResult = false;
            showScore= false;

            getCurrentClip(clipscreen["data"]["clip_id"]);

          }

          // context.read<EventBloc>().add(GetClipInfoEvent(clip_id: clipscreen["data"]["clip_id"].toString()));
        }else{
          if(fireData['gameActivated'] == null){
            _player.stop();
            dbSub.cancel();
            logout(context);
          }
        }

      }


    });


  }

  void calculatePlayersAndRanking(Map<String, dynamic> scoreMap, String currentClipID) {
    if (scoreMap.isEmpty) return;
    String clipid ='';
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
      totalUserScore= players[i]['totalScore'];
       name = players[i]["full_name"];

      clipid = players[i]['clip_id'].toString();
      if (userId.toString() == userModel.user?.id.toString()) {
        currentRanking = i + 1; // rank starts from 1

        break;
      }
    }

    debugPrint("Total Players = $totalPlayers");
    debugPrint("Current Ranking = $currentRanking");
    debugPrint("Show Score :: ${clipid == currentClipID} :: ${currentClipID} :: ${clipid}  :: ${showScore}");
    if(clipid ==currentClipID){
      showScore=true;
    }
    if (mounted) {
      setState(() {});
    }
  }


  getCurrentClip(int clipid){
    currentClip = gameDataModel.clips!.firstWhere(
          (element) => element.clipId.toString() == clipid.toString(),
      orElse: () => Clip(),  // use your empty model
    );

    String level = currentClip.clipLevel ?? "";  // example: "Ga"
    Score score = gameDataModel.score!;


    switch (level) {
      case "Sa": currentClipScore = score.sa ?? 0; break;
      case "Re": currentClipScore = score.re ?? 0; break;
      case "Ga": currentClipScore = score.ga ?? 0; break;
      case "Ma": currentClipScore = score.ma ?? 0; break;
      case "Pa": currentClipScore = score.pa ?? 0; break;
    }
   totalScore += currentClipScore;
    current = currentClip.timerLength?.toDouble() ?? 0;
    // startTimer();
    setState(() {

    });
    startTimer();
    playAudio("${AppUrl.clipBAseUrl}/${currentClip.clipFileName}");


  }

  getGameData()async{
    var map = await LocalStorage.readModel("get_game_data");
    if (map != null) {
      gameDataModel = GetGameDataModel.fromJson(map);
    }
  }

  Future<void> playAudio(String url) async {
    if(gameDataModel.gameSound?.toLowerCase().contains("off") ?? false) return;
    try {
      await _player.setUrl(url);
      _player.play();
    } catch (e) {
    }
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

  submitAnswer(String answerId,String answer){
    
    int clipTimer = currentClip.timerLength ?? 0;
    var responseTime = clipTimer-current;
    int clipScore = currentClipScore;
    
    var score = (1-responseTime/clipTimer/2)*clipScore;

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
        title: Text("HFMGame",style: TextStyle(
          fontWeight: FontWeight.w500
        ),),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.lightestGrey
            ),
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            margin: EdgeInsets.only(right: 10),
            child: Text("${currentClip.clipOrderNo ?? 0}/${(gameDataModel.clips?.length ?? 0) -1}",
            style: TextStyle(
              color: Colors.black
            ),),
          )
        ],
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if(state.clipInfoStatus == EventStatus.completed){
            GetClipInfoModel? getClipInfoModel = state.clipInfoModel;
            // playAudio(getClipInfoModel?.data?.thumbnail ?? "");
            // startTimer();
          }
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
                  padding: const EdgeInsets.only(left: 10.0,right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(
                        currentClip.clipLevel?.toLowerCase().contains("sa") ?? false
                        ? AppImages.saRectLeft
                    : currentClip.clipLevel?.toLowerCase().contains("re") ?? false
                            ?AppImages.reRectLeft
                            : currentClip.clipLevel?.toLowerCase().contains("ga") ?? false
                            ?AppImages.gaRectLeft
                            : currentClip.clipLevel?.toLowerCase().contains("ma") ?? false
                            ?AppImages.maRectLeft
                            :AppImages.paRectLeft

                    ),
                      fit: BoxFit.fill,     // fills the container
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
                      height:20),
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
                  padding: const EdgeInsets.only(left: 10.0,right: 10),
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(
                          currentClip.clipLevel?.toLowerCase().contains("sa") ?? false
                              ? AppImages.saRectRight
                              : currentClip.clipLevel?.toLowerCase().contains("re") ?? false
                              ?AppImages.reRectRight
                              : currentClip.clipLevel?.toLowerCase().contains("ga") ?? false
                              ?AppImages.gaRectRight
                              : currentClip.clipLevel?.toLowerCase().contains("ma") ?? false
                              ?AppImages.maRectRight
                              :AppImages.paRectRight
                      ),
                        fit: BoxFit.fill,     // fills the container
                      )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                          currentClip.clipLevel?.toLowerCase().contains("sa") ?? false
                              ? AppImages.saStar
                              : currentClip.clipLevel?.toLowerCase().contains("re") ?? false
                              ?AppImages.reStar
                              : currentClip.clipLevel?.toLowerCase().contains("ga") ?? false
                              ?AppImages.gaStar
                              : currentClip.clipLevel?.toLowerCase().contains("ma") ?? false
                              ?AppImages.maStar
                              :AppImages.paStar
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
            Text("Do you recognize the song? \n Click on your answer below.",
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
                        ignoring: performAnswer ,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: performAnswer
                              ? (selectedOption == 1 || (currentClip.options?[0].clipCorrectOption.toString().contains("C") ?? false) ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              if(current == 0) return;
                              selectedOption =1;
                              performAnswer= true;

                              pauseTimer();
                              submitAnswer(currentClip.options?[0].id.toString() ?? "",currentClip.options?[0].clipCorrectOption.toString() ?? "");
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *.2,
                                    width: MediaQuery.of(context).size.width *.4,
                                    decoration: BoxDecoration(
                                      color: AppColors.op1Color,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        width: performAnswer  && (((currentClip.options?[0].clipCorrectOption.toString().contains("W") ?? false) && selectedOption == 1) || (currentClip.options?[0].clipCorrectOption.toString().contains("C") ?? false))
                                            ? 4 :0,
                                        color: performAnswer  && (currentClip.options?[0].clipCorrectOption.toString().contains("C") ?? false)
                                          ? AppColors.rightAnswerColor
                                            : performAnswer  && selectedOption == 1 && (currentClip.options?[0].clipCorrectOption.toString().contains("W") ?? false)
                                          ? AppColors.wrongAnswerColor
                                            : Colors.white
                                      )
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Image.asset(AppImages.Option1Icon,
                                            height: 20,
                                            width: 20,)),
                                        const SizedBox(height: 15,),
                                        Expanded(
                                          child: Center(
                                            child: Text("${currentClip.options?[0].clipOptionDesc.toString()}",
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

                                performAnswer && selectedOption == 1 && (currentClip.options?[0].clipCorrectOption.toString().contains("W") ?? false) ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && (currentClip.options?[0].clipCorrectOption.toString().contains("C") ?? false) ?
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
                        ignoring: performAnswer ,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: performAnswer
                              ? (selectedOption == 2 || (currentClip.options?[1].clipCorrectOption.toString().contains("C") ?? false) ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              if(current == 0) return;

                              selectedOption =2;
                              performAnswer= true;

                              pauseTimer();
                              submitAnswer(currentClip.options?[1].id.toString() ?? "",currentClip.options?[1].clipCorrectOption.toString() ?? "");

                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *.2,
                                    width: MediaQuery.of(context).size.width *.4,
                                    decoration: BoxDecoration(
                                        color: AppColors.op2Color,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: performAnswer  && (((currentClip.options?[1].clipCorrectOption.toString().contains("W") ?? false) && selectedOption == 2) || (currentClip.options?[0].clipCorrectOption.toString().contains("C") ?? false))
                                                ? 4 :0,
                                            color: performAnswer  && (currentClip.options?[1].clipCorrectOption.toString().contains("C") ?? false)
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 2 && (currentClip.options?[1].clipCorrectOption.toString().contains("W") ?? false)
                                                ? AppColors.wrongAnswerColor
                                                : Colors.white
                                        )

                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Image.asset(AppImages.Option2Icon,
                                              height: 20,
                                              width: 20,)),
                                        const SizedBox(height: 15,),

                                        Expanded(
                                          child: Center(
                                            child: Text("${currentClip.options?[1].clipOptionDesc.toString()}",
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
                              performAnswer && selectedOption == 2 && (currentClip.options?[1].clipCorrectOption.toString().contains("W") ?? false) ?
                              Image.asset(AppImages.wrong,
                              width: 30,
                              height: 30,) : Container(),

                                performAnswer && (currentClip.options?[1].clipCorrectOption.toString().contains("C") ?? false)  ?
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
                        ignoring: performAnswer ,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: performAnswer
                              ? (selectedOption == 3 || (currentClip.options?[2].clipCorrectOption.toString().contains("C") ?? false) ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              if(current == 0) return;

                              selectedOption =3;
                              performAnswer= true;

                              pauseTimer();
                              submitAnswer(currentClip.options?[2].id.toString() ?? "",currentClip.options?[2].clipCorrectOption.toString() ?? "");

                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *.2,
                                    width: MediaQuery.of(context).size.width *.4,
                                    decoration: BoxDecoration(
                                        color: AppColors.op3Color,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: performAnswer &&  ((currentClip.options?[2].clipCorrectOption.toString().contains("C") ?? false)|| selectedOption == 3)
                                                ? 4 :0,
                                            color: performAnswer  && (currentClip.options?[2].clipCorrectOption.toString().contains("C") ?? false)
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 3 && (currentClip.options?[2].clipCorrectOption.toString().contains("W") ?? false)
                                                ? AppColors.wrongAnswerColor
                                                : Colors.white
                                        )

                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Image.asset(AppImages.Option3Icon,
                                              height: 20,
                                              width: 20,)),
                                        const SizedBox(height: 15,),
                                        Expanded(
                                          child: Center(
                                            child: Text("${currentClip.options?[2].clipOptionDesc.toString()}",
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
                                performAnswer && selectedOption == 3 && (currentClip.options?[2].clipCorrectOption.toString().contains("W") ?? false) ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && (currentClip.options?[2].clipCorrectOption.toString().contains("C") ?? false)  ?
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
                        ignoring: performAnswer ,
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: performAnswer
                              ? (selectedOption == 4 || (currentClip.options?[3].clipCorrectOption.toString().contains("C") ?? false) ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              if(current == 0) return;

                              selectedOption =4;
                              performAnswer= true;

                              pauseTimer();
                              submitAnswer(currentClip.options?[3].id.toString() ?? "",currentClip.options?[3].clipCorrectOption.toString() ?? "");

                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,

                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *.2,
                                    width: MediaQuery.of(context).size.width *.4,
                                    decoration: BoxDecoration(
                                        color: AppColors.op4Color,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: performAnswer  && (selectedOption == 4 || (currentClip.options?[3].clipCorrectOption.toString().contains("C") ?? false))
                                                ? 4 :0,
                                            color: performAnswer  && (currentClip.options?[3].clipCorrectOption.toString().contains("C") ?? false)
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 4 && (currentClip.options?[3].clipCorrectOption.toString().contains("W") ?? false)
                                                ? AppColors.wrongAnswerColor
                                                : Colors.white
                                        )

                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: Image.asset(AppImages.Option4Icon,
                                              height: 20,
                                              width: 20,)),
                                        const SizedBox(height: 15,),

                                        Expanded(
                                          child: Center(
                                            child: Text("${currentClip.options?[3].clipOptionDesc.toString()}",
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
                                performAnswer && selectedOption == 4 && (currentClip.options?[3].clipCorrectOption.toString().contains("W") ?? false) ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && (currentClip.options?[3].clipCorrectOption.toString().contains("C") ?? false)  ?
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
                      trackHeight: 10, // Bigger slider


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
                      color: AppColors.op2Color,

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
                      color: answerPerform == 'right' ? AppColors.op4Color : AppColors.primaryColor,

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
                        color: answerPerform == 'right' ? AppColors.op4Color : AppColors.primaryColor,

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
                        color: answerPerform == 'right' ? AppColors.op4Color : AppColors.primaryColor,

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


          ],
        ),
      ),
    );
  }
}

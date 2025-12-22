import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gaanap_admin_new/models/final_scoreboard_model.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/views/finalscorecard/widget/scores.dart';
import 'package:gaanap_admin_new/views/finalscorecard/widget/winner_ribbon_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_url.dart';
import '../../config/routes/routes_name.dart';
import '../../services/session_controller/session_controller.dart';
import '../../services/storage/local_storage.dart';
import '../../utils/Utils.dart';

class FinalScorecard extends StatefulWidget  {
  final String gameid;
  const FinalScorecard({Key? key,required this.gameid}) : super(key: key);

  @override
  State<FinalScorecard> createState() => _FinalScorecardState();
}

class _FinalScorecardState extends State<FinalScorecard> {
  late FirebaseDatabase db1;
  late DatabaseReference dbref;
  var fireData;
  late StreamSubscription<DatabaseEvent> dbSub;

  String name= '';
  List<FinalScoreModel> finalScoreList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db1 = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppUrl.firebaseUrl,
    );
    dbref = db1.ref(AppUrl.fireDatabaseName);
    fireDataManage();
  }

  fireDataManage() async{
    dbSub = dbref.onValue.listen((event) {
      final data = event.snapshot.value;
      fireData=data;
      debugPrint("🔥 REALTIME DATA: $data");
      if(fireData != null){
        var clipscreen = fireData["globalClipScreenChange"];
        var globalFinalScoreboard = fireData["globalFinalScoreboard"];



        if(clipscreen != null){
          if(globalFinalScoreboard != null && globalFinalScoreboard['data'] != null){
            final rawFinalScoreData =
            fireData["globalFinalScoreboard"]?["data"];

            buildFinalScoreboard(rawFinalScoreData);
          }
          // context.read<EventBloc>().add(GetClipInfoEvent(clip_id: clipscreen["data"]["clip_id"].toString()));
        }else{
          dbSub.cancel();
          logout(context);

        }

      }


    });

  }


  void buildFinalScoreboard(dynamic rawData) {
    if (rawData == null) return;

    final List<Map<String, dynamic>> tempList = [];

    // 🔹 Handle MAP
    if (rawData is Map) {
      for (final value in rawData.values) {
        if (value is Map) {
          tempList.add(Map<String, dynamic>.from(value));
        }
      }
    }

    // 🔹 Handle LIST
    else if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          tempList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    // ❌ No data
    if (tempList.isEmpty) return;

    // 🔥 Sort by totalScore DESC
    tempList.sort((a, b) {
      final scoreA = a["totalScore"] ?? 0;
      final scoreB = b["totalScore"] ?? 0;
      return scoreB.compareTo(scoreA);
    });

    // ✅ Convert to model list
    finalScoreList = tempList
        .map((e) => FinalScoreModel.fromJson(e))
        .toList();

    // debugPrint("Final Scoreboard = ${finalScoreList.length}");

    if (mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height *.45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color:AppColors.primaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))
                ),
                padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Final Scorecard ",
                          style: GoogleFonts.roboto(
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            color: Colors.white,

                          ),
                        ),
                        TextSpan(
                          text: "(Top 10 players) ",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                            color: Colors.white,

                          ),
                        ),



                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Image.asset(AppImages.crown),
                    Row(
            children: [
              Expanded(
                child: WinnerRibbonWidget(
                  ribbonImage: AppImages.ribbon2,
                  name: finalScoreList.length > 1
                      ? finalScoreList[1].fullName
                      : "No User",
                  score: finalScoreList.length > 1
                      ? finalScoreList[1].totalScore
                      : 0,
                  profileImage:finalScoreList.length > 1
                      ? finalScoreList[1].profilePhoto : "",
                  topMargin: 60,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: WinnerRibbonWidget(
                  ribbonImage: AppImages.ribbon1,
                  name: finalScoreList.length > 0
                      ? finalScoreList[0].fullName
                      : "No User",
                  score: finalScoreList.length > 0
                      ? finalScoreList[0].totalScore
                      : 0,
                  profileImage:finalScoreList.length > 0
                      ? finalScoreList[0].profilePhoto :"",
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: WinnerRibbonWidget(
                  ribbonImage: AppImages.ribbon3,
                  name: finalScoreList.length > 2
                      ? finalScoreList[2].fullName
                      : "No User",
                  score: finalScoreList.length > 2
                      ? finalScoreList[2].totalScore
                      : 0,
                  profileImage: finalScoreList.length > 2
                      ? finalScoreList[2].profilePhoto :"",
                  topMargin: 80,
                ),
              ),
            ],
          ),

                ],
              ),
              ),
              Visibility(
                visible: finalScoreList.length > 3,
                child: Expanded(child:
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: ListView.separated(
                  itemBuilder: (context,index){
                    return Scores(model: finalScoreList[index],index: index,);
                  },
                    separatorBuilder: (context,index){
                  return Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                    color: Colors.grey.shade300,
                  );
                              },
                   itemCount: finalScoreList.length,
                  ),
                ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

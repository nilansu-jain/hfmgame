import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/views/gamebegain/widgets/graph.dart';
import 'package:gaanap_admin_new/views/gamebegain/widgets/textthumbshape.dart';
import 'package:just_audio/just_audio.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  double current = 20; // Start from 20 seconds
  Timer? timer;
  Color sliderColor = AppColors.timerInitial;
  bool isPaused = false;

  int selectedOption =0;
  bool performAnswer = false;
  bool wrongAnswer = false;
  int rightAnswer =0;
  
  bool showResult = false;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();

    playAudio();



  }
  Future<void> playAudio() async {
    try {
      await _player.setAsset(AppImages.audio);
      print("Loaded duration: ${_player.duration}");
      _player.play();
    } catch (e) {
      print("ERROR: $e");
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

  void resultTimer(){
    Future.delayed(Duration(seconds: 5), () {
      showResult= true;
      gameOver();
      setState(() {

      });
    });
  }
  void gameOver(){
    Future.delayed(Duration(seconds: 5), () {
     Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.gameOver, (route) => false);
    });
  }

  void pauseTimer() {
    _player.pause();
    setState(() {
      isPaused = true;
      resultTimer();
    });
  }
  @override
  void dispose() {
    _player.dispose();
    timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Text("1/16",
            style: TextStyle(
              color: Colors.black
            ),),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 130,
                  padding: const EdgeInsets.only(left: 10.0,right: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(AppImages.saRectLeft),
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
                      Text("Sa",
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
                      image: DecorationImage(image: AssetImage(AppImages.saRectRight),
                        fit: BoxFit.fill,     // fills the container
                      )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.saStar),
                      const SizedBox(width: 10,),
                      Text("800",
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
            Text("Select the answer choice according to \n listen clip?",
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
                              ? (selectedOption == 1 || rightAnswer == 1 ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              selectedOption =1;
                              performAnswer= true;
                              wrongAnswer = true;
                              rightAnswer=2;
                              pauseTimer();
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
                                        width: performAnswer  && (rightAnswer == 1 || wrongAnswer)
                                            ? 4 :0,
                                        color: performAnswer  && rightAnswer == 1
                                          ? AppColors.rightAnswerColor
                                            : performAnswer  && selectedOption == 1 && wrongAnswer
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
                                            child: Text("One Two Cha Cha Cha",
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

                                performAnswer && selectedOption == 1 && wrongAnswer ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && rightAnswer == 1  ?
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
                              ? (selectedOption == 2 || rightAnswer == 2 ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              selectedOption =2;
                              performAnswer= true;
                              wrongAnswer = true;
                              rightAnswer=3;
                              pauseTimer();
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
                                            width: performAnswer  && (rightAnswer == 2 || wrongAnswer)
                                                ? 4 :0,
                                            color: performAnswer  && rightAnswer == 2
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 2 && wrongAnswer
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
                                            child: Text("Dum maro dum",
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
                              performAnswer && selectedOption == 2 && wrongAnswer ?
                              Image.asset(AppImages.wrong,
                              width: 30,
                              height: 30,) : Container(),

                                performAnswer && rightAnswer == 2  ?
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
                              ? (selectedOption == 3 || rightAnswer == 3 ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              selectedOption =3;
                              performAnswer= true;
                              wrongAnswer = true;
                              rightAnswer=4;
                              pauseTimer();
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
                                            width: performAnswer &&  (rightAnswer == 3 || wrongAnswer)
                                                ? 4 :0,
                                            color: performAnswer  && rightAnswer == 3
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 3 && wrongAnswer
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
                                            child: Text("Duniya mai logon ko",
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
                                performAnswer && selectedOption == 3 && wrongAnswer ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && rightAnswer == 3  ?
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
                              ? (selectedOption == 4 || rightAnswer == 4 ? 1.0 : 0.4)  // fade others
                              : 1.0,
                          child: InkWell(
                            onTap:(){
                              selectedOption =4;
                              performAnswer= true;
                              wrongAnswer = true;
                              rightAnswer=1;
                              pauseTimer();
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
                                            width: performAnswer  && (rightAnswer == 4 || wrongAnswer)
                                                ? 4 :0,
                                            color: performAnswer  && rightAnswer == 4
                                                ? AppColors.rightAnswerColor
                                                : performAnswer  && selectedOption == 4 && wrongAnswer
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
                                            child: Text("Piya tu ab to aa ja",
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
                                performAnswer && selectedOption == 4 && wrongAnswer ?
                                Image.asset(AppImages.wrong,
                                  width: 30,
                                  height: 30,) : Container(),

                                performAnswer && rightAnswer == 4  ?
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
                    ? FourBarGraph()
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
    );
  }
}

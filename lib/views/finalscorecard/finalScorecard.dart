import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/views/finalscorecard/widget/scores.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalScorecard extends StatefulWidget  {
  const FinalScorecard({Key? key}) : super(key: key);

  @override
  State<FinalScorecard> createState() => _FinalScorecardState();
}

class _FinalScorecardState extends State<FinalScorecard> {
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
                        child: Container(
                          margin: const EdgeInsets.only(top: 60.0),
                          child: Column(
                            children: [
                              Text("Meenakshi",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16
                              ),),
                              Stack(
                                children: [
                                  Image.asset(AppImages.ribbon2),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.op1Color),
                                      shape: BoxShape.circle
                                    ),
                                    padding: EdgeInsets.all(5),
                                    alignment: Alignment.center,
                                    child: Text("2",),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          children: [
                            Text("Priyanka",
                              style: TextStyle(
                                  color: Colors.white,
                                fontSize: 16
                              ),),
                            Image.asset(AppImages.ribbon1)
                          ],
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 60.0),
                          child: Column(
                            children: [
                              Text("Meenakshi",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                ),),
                              Image.asset(AppImages.ribbon3)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
              ),
              Expanded(child:
              Container(
                margin: EdgeInsets.only(top: 10),
                child: ListView.separated(
                itemBuilder: (context,index){
                  return Scores();
                },
                            separatorBuilder: (context,index){
                return Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                  color: Colors.grey.shade300,
                );
                            },
                 itemCount: 7,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/routes/routes_name.dart';

class GameOver extends StatefulWidget {
  const GameOver({Key? key}) : super(key: key);

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5),(){
      Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.finalScorecard, (route) => false);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.scorecardBg,),
            fit: BoxFit.fill
          ),
        ),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.star),
            const SizedBox(height: 20),
            Text(
              "Awesome Nilansu",
              style: GoogleFonts.roboto(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            Text(
              "You got the right!",
              style: GoogleFonts.roboto(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
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
                    text: "+720 ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      color: AppColors.op2Color,

                    ),
                  ),
                  TextSpan(
                    text: "and your \n Total is now ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Colors.white,

                    ),
                  ),
                  TextSpan(
                    text: "+1420 ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      color: AppColors.op4Color,

                    ),
                  ),


                ],
              ),
            ),

            const SizedBox(height: 50),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You added And you are now \n ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: Colors.white,

                    ),
                  ),
                  TextSpan(
                    text: "4 out of 17 ",
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      color: AppColors.op4Color,

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


          ],
        ),
      ),
    );
  }
}

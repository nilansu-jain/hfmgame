import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

class GameLoading extends StatefulWidget {
  const GameLoading({Key? key}) : super(key: key);

  @override
  State<GameLoading> createState() => _GameLoadingState();
}

class _GameLoadingState extends State<GameLoading> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
       Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.gameScreen, (route) => false);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child:
        Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(AppImages.background,
              fit: BoxFit.fill,
              height: MediaQuery.of(context).size.height *.58,
              width: MediaQuery.of(context).size.width,),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text("Welcome to \n HFMGame!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,),

                Spacer(),
                Center(
                  child: Image.asset(AppImages.play,
                  height: 100,
                  width: 100,),
                ),
                Spacer(),

                Text("Please wait ....",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                  ),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 5),
                Text("The game will start soon!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    color: Colors.white
                  ),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 50,),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

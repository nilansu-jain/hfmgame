import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

import '../../bloc/event/event_bloc.dart';
import '../../config/app_url.dart';
import '../../main.dart';
import '../../utils/Utils.dart';

class GameLoading extends StatefulWidget {
  final String hostid;
  final String gameid;

  const GameLoading({Key? key,
  required this.gameid,
  required this.hostid}) : super(key: key);

  @override
  State<GameLoading> createState() => _GameLoadingState();
}

class _GameLoadingState extends State<GameLoading> {

  late EventBloc _eventBloc;
  late FirebaseDatabase db1;
  late DatabaseReference dbref;
  var fireData;
  late StreamSubscription<DatabaseEvent> dbSub;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db1 = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppUrl.firebaseUrl,
    );
    dbref = db1.ref(AppUrl.fireDatabaseName);
    _eventBloc= EventBloc(eventRepository: getit());
    dbSub= dbref.onValue.listen((event) {
      final data = event.snapshot.value;
      fireData=data;
      debugPrint("🔥 REALTIME DATA: $data");
      if(fireData != null){
        var clipscreen = fireData["globalClipScreenChange"];

        if(clipscreen != null){
          dbSub.cancel();  // 💥 stops listening instantly
          Navigator.of(context).pushNamedAndRemoveUntil(RoutesName.gameScreen, (route) => false,
            arguments: {
              "game_id": widget.gameid,
              "host_id": widget.hostid,
            },);
        }

      }


    });

    context.read<EventBloc>().add(GetGameDataEvent(game_id: widget.gameid,
        host_id: widget.hostid,));

  }

  @override
  void dispose() {
    dbSub.cancel(); // 🔥 stops Firebase stream
    super.dispose();
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

                // Visibility(
                //
                //   child: Center(
                //     child: Image.asset(AppImages.logo,
                //     height: 300,
                //     width: 300,),
                //   ),
                // ),
                Center(
                  child: Container(),
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

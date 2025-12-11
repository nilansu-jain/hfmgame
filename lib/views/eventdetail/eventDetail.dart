import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gaanap_admin_new/bloc/event/event_bloc.dart';
import 'package:gaanap_admin_new/config/routes/routes_name.dart';
import 'package:gaanap_admin_new/main.dart';
import 'package:gaanap_admin_new/models/user/user_model.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/services/session_controller/session_controller.dart';
import 'package:gaanap_admin_new/utils/Utils.dart';
import 'package:gaanap_admin_new/utils/enums.dart';

import '../../res/color/colors.dart';
import '../../services/storage/local_storage.dart';



class EventDetails extends StatefulWidget {
  const EventDetails({Key? key}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  
  bool isActive = false;
  late UserModel userModel ;
  late EventBloc _eventBloc;

  late FirebaseDatabase db1;
  late DatabaseReference dbref;


  var gameId;
  var hostId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    db1 = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://hfmgame-live.firebaseio.com",
    );

    dbref = db1.ref("gplgame");

    dbref.onValue.listen((event) {
      final data = event.snapshot.value;

      print("🔥 REALTIME DATA: $data");

    });

    _eventBloc= EventBloc(eventRepository: getit());
    userModel= SessionController().userModel;
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isActive = true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.6),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Center(child: Text("${userModel.gameDetails?.gameTitle ?? ""}",
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),)),
        actions: [
          IconButton(onPressed: (){

            LocalStorage localStorage = LocalStorage();
            localStorage.deleteData('user').then((value){
              localStorage.deleteData('isLogin').then((value) {
                Navigator.of(context).pushNamed(RoutesName.splashScreen);
              });
            });
          },
              icon: Icon(Icons.logout)),
        ],

      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(userModel.gameDetails?.thumbnail ?? '',
            height: MediaQuery.of(context).size.height *.3,
            fit: BoxFit.fill,),
            const SizedBox(height: 20,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10),
            child:             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userModel.gameDetails?.gameName ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  ),),
                const SizedBox(height: 10,),
                Text("${userModel.gameDetails?.eventDate ?? "No Date Available"}",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                  ),),

                const SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(Icons.watch_later_outlined,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5,),

                    Text("IST",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        )
                    ),
                    const SizedBox(width: 10,),

                    Text("09:00 AM",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400
                      ),),

                    const SizedBox(width: 20,),

                    Text("CST",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        )
                    ),
                    const SizedBox(width: 10,),

                    Text("09:30 PM",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400
                      ),),
                  ],
                ),

                const SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(Icons.list,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5,),

                    Text("Questions",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        )
                    ),
                    const SizedBox(width: 10,),

                    Text("${userModel.gameDetails?.noOfClips ?? ""}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400
                      ),),
                  ],
                )
              ],
            )
              ,),
            Spacer(),
            BlocConsumer<EventBloc, EventState>(
              listener: (context, state) {
                if(state.apiStatus == EventStatus.completed){
                  showToast(state.message);
                }
                if(state.apiStatus == EventStatus.error){
                  showToast(state.message);
                }
              },
              builder: (context, state) {
                return InkWell(
              onTap: (){
                if(isActive){
                  context.read<EventBloc>().add(JoinEvent(game_id: gameId.toString() ?? "0",
                      host_id: hostId.toString(),
                      user_id: userModel.user?.id.toString() ?? "0"));
                  // Navigator.of(context).pushNamed(RoutesName.gameLoading);
                }else{
                  showToast("Game is not available right now");
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20)
                ),
                child:
                state.apiStatus == EventStatus.loading
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.white,),
                )
                    :
                Text("JOIN",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,),
              ),
            );
  },
)
          ],
        ),
      ),
    );
  }
}

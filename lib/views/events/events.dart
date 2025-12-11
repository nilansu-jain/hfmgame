import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/views/events/widgets/eventItem.dart';

class GameEvents extends StatefulWidget {
  const GameEvents({Key? key}) : super(key: key);

  @override
  State<GameEvents> createState() => _GameEventsState();
}

class _GameEventsState extends State<GameEvents> {

  List<String> eventType= ["Upcoming Event","Ongoing Event", "Past Event"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("GaanaP Live",
          style: TextStyle(
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.center,),
        ),

      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: ListView.separated(itemBuilder: (context,index){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eventType[index],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 24
              ),
              textAlign: TextAlign.start,),
              const SizedBox(height: 10,),
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    return EventItem();
                  },
                  separatorBuilder: (context,index){
                return const SizedBox(height: 10,);
                  },
                  itemCount: 3)
            ],
          );
        },
            separatorBuilder: (context,index){
          return const SizedBox(height: 10,);
            },
            itemCount: eventType.length),
      ),
    );
  }
}

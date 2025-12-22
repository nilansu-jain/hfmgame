import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/models/final_scoreboard_model.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

class Scores extends StatelessWidget {
  final FinalScoreModel model;
  final int index;
   Scores({Key? key, required this.model, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 25),
            child: Text("${index+1}"),
          ),
          const SizedBox(width: 20,),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 27,
              backgroundImage: model.profilePhoto != null
                  ? AssetImage(model.profilePhoto!)
                  : null,
              child: model.profilePhoto == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
          ),

          const SizedBox(width: 20,),

          Text("${model.fullName}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18
          ),
          overflow: TextOverflow.ellipsis,),
          Spacer(),
          Text("${model.totalScore}",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18
            ),),
          const SizedBox(width: 20,)
        ],
      ),
    );
  }
}

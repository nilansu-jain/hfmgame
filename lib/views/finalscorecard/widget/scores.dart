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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomLeft: Radius.circular(20)),

            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 4,horizontal: 20),
            child: Text("${index+1}"),
          ),
          const SizedBox(width: 20,),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 30,
              backgroundImage:getProfileImage(model.profilePhoto),
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

  ImageProvider getProfileImage(String? image) {
    if (image == null || image.isEmpty) {
      return AssetImage(AppImages.noUserImage);
    } else if (image.startsWith('http')) {
      return NetworkImage(image);
    } else {
      return AssetImage(AppImages.noUserImage);
    }
  }

}

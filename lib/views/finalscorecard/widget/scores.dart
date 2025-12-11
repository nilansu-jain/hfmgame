import 'package:flutter/material.dart';
import 'package:gaanap_admin_new/res/images/images.dart';

class Scores extends StatelessWidget {
  const Scores({Key? key}) : super(key: key);

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
            child: Text("25"),
          ),
          const SizedBox(width: 20,),
          ClipOval(
            child: Image.asset(AppImages.star,
            height: 50,
            width: 50,),
          ),
          const SizedBox(width: 20,),

          Text("Krishna",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18
          ),
          overflow: TextOverflow.ellipsis,),
          Spacer(),
          Text("19886",
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

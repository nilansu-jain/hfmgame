import 'package:flutter/material.dart';

import '../color/colors.dart';

class InternetExcepton extends StatelessWidget {

  final VoidCallback onPress;

  const InternetExcepton({Key? key,
  required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.signal_wifi_connected_no_internet_4,
        color: AppColors.red,
        size: 100,),
        SizedBox(height: MediaQuery.of(context).size.height*.05,),
        Text("No Internet \n Please try again later",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),

        SizedBox(height:MediaQuery.of(context).size.height*.05 ,),

        ElevatedButton(
            onPressed: onPress,
            child:
             Text("Retry",style: TextStyle(
            color: Colors.black
             ),))


      ],
    );
  }
}

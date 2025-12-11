import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color/colors.dart';

class RoundButton extends StatelessWidget {
  final VoidCallback onPress;
  final double height,width;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final String title;

  const RoundButton({Key? key,
  required this.onPress, this.height = 40,
  this.width = 100,
  this.buttonColor = AppColors.blue,
  this.textColor = AppColors.white,
  this.borderRadius = 10,
  required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(title,
          style: TextStyle(
            color: textColor
          ),),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color/colors.dart';

class LoadingWidget extends StatefulWidget {
  final Color color;
  final double size;
  const LoadingWidget({Key? key,
  this.color = AppColors.blue,
  this.size = 40}) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: SizedBox(
          height: widget.size,
          width: widget.size,
          child:    Platform.isAndroid
              ?
          CircularProgressIndicator(
            color:widget.color ,
          )
              :
          CupertinoActivityIndicator(
            color: widget.color,
          ) ,
        ),
      )
  ;
  }
}

import 'package:flutter/material.dart';

//Widget appBarMain(BuildContext context) {
//  return AppBar(
//    title: Image.asset(
//      "assets/images/logo.png",
//      height: 40,
//    ),
//    elevation: 0.0,
//    centerTitle: false,
//  );
//}
//

//TextField InputDecoration
InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white38),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)));
}

//스타일, 위젯
TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.black, fontSize: 12);
}

//파일 클릭하면 나오는 화면
//등록한 파일 볼 수 있음

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyspace/screens/test.dart';
import 'dart:io';

//화면
import 'package:studyspace/widget/widget.dart'; //스타일

class MyPage extends StatefulWidget {
  MyPage({Key key, this.title, this.urls}) : super(key: key);
  final String title;
  final String urls;

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
 Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      title: 'Flutter layout demo',
      home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/img/background.png"),
                  fit: BoxFit.cover)),
        child: Scaffold(
          appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text('마이페이지'),
                  centerTitle: true,
                  leading: new IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),),
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );
  }
}

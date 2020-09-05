import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:studyspace/screens/file_list.dart';
import 'package:flutter_filereader/flutter_filereader.dart';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

//화면
import 'file:///C:/dev/studyspace/lib/screens/calendar.dart'; //복습일정화면
import 'package:studyspace/screens/login.dart'; //로그인화면
import 'package:studyspace/widget/widget.dart'; //스타일

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  FirebaseUser user;
  String email;

  //행성이름 controller
  final _planetNamecontroller = TextEditingController();

  @override
  initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //firebase auth User
    _auth.currentUser().then((value) => value.email);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/img/background.png"),
                  fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text('Study Space'),
              centerTitle: true,
              actions: [
                IconButton(icon: Icon(Icons.alarm_on), onPressed: null),
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: null,
                )
              ],
            ),
            body: FileReaderView(
              filePath: "https://pdftron.s3.amazonaws.com/downloads/pdfref.pdf",
    ),),),);}}
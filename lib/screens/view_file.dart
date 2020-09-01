//파일 클릭하면 나오는 화면
//등록한 파일 볼 수 있음

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//화면
import 'package:studyspace/widget/widget.dart'; //스타일

class ViewFile extends StatefulWidget {
  ViewFile({Key key, this.title, this.urls}) : super(key: key);
  final String title;
  final String urls;

  @override
  _ViewFileState createState() => _ViewFileState(title: title, urls: urls);
}

class _ViewFileState extends State<ViewFile> {
  String title; //파일 이름
  String urls; //
  _ViewFileState({this.title, this.urls});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final db = Firestore.instance;
  FirebaseUser user;
  String email;
  File _image; //추가 이미지
  String _imageURL; //추가 이미지 url

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
              title: Text(title),
              centerTitle: true,
              leading: new IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: urls.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: EdgeInsets.all(10.0),
                      child: FittedBox(
                        child: Image.network(urls),
                        fit: BoxFit.fill,
                      ));
                }),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Hexcolor('#7195C1'),
              onPressed: () {},
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          )),
    );
  }}





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

class ViewFile extends StatefulWidget {
  ViewFile({Key key, this.title, this.file, this.urls}) : super(key: key);
  final String title; //제목이름
  final String file; //파일이름
  final String urls;

  @override
  _ViewFileState createState() =>
      _ViewFileState(title: title, file: file, urls: urls);
}

class _ViewFileState extends State<ViewFile> {
  String title; //행성 이름
  String file; //파일 이름
  String urls; //
  _ViewFileState({this.title, this.file, this.urls});

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
                  title: Text(file),
                  centerTitle: true,
                  leading: new IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.photo_album),
                      tooltip: 'Hi!',
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Test()),
                        )
                      },
                    ),
                    new IconButton(
                      icon: new Icon(Icons.pie_chart),
                      tooltip: 'Wow',
                      onPressed: () => {},
                    )
                  ],
                ),
                body: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          padding: EdgeInsets.all(10.0),
                          child: FittedBox(
                            child: Image.network(urls),
                            fit: BoxFit.fill,
                          ));
                    }),
                floatingActionButton: FloatingActionButton(
                    backgroundColor: Hexcolor('#7195C1'),
                    onPressed: () {
                      _reviewCountPlus();
                    },
                    child: StreamBuilder(
                        stream: getUsersFileListStreamSnapshots(context),
                        builder: (context, snapshot) {
                          var data = snapshot.data.documents[0];
                          var reviewCount = data['reviewCount'];
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());
                          return Container(child: Text('복습$reviewCount/5'));
                        })),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat)));
  }

//
//              floatingActionButton: FloatingActionButton(
//          child: Container(child: Text('복습')),
//      backgroundColor: Hexcolor('#7195C1'),
//      onPressed: () {},
//    ),
//    floatingActionButtonLocation:
//    FloatingActionButtonLocation.centerFloat
//          )),
//    );
//  }

  //복습 다해서 firestore reviewCount 숫자 올리기
  void _reviewCountPlus() async {

    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    var b;
    var a;

    //복습 횟수 가져오기
    await Firestore.instance.collection("review").document(uid)
        .collection(title) //행성이름
        .document(file) //파일
        .collection("review")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => a=('${f.data['reviewCount']}')

      );
      print(a);
      b=int.parse(a);
      b++;
    });



    Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(file) //파일
        .collection("review")
        .document("1")
        .updateData({'reviewCount': b});
  }

  Stream<QuerySnapshot> getUsersFileListStreamSnapshots(
      BuildContext context) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(file) //파일
        .collection("review")
        .snapshots();
  }
}

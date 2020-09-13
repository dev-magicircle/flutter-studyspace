//파일 클릭하면 나오는 화면
//등록한 파일 볼 수 있음

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:vector_math/vector_math_64.dart'
    show Vector3; //이미지 줌인, 줌아웃 하는 데 쓸 패키지
import 'package:image_picker/image_picker.dart';
import 'package:studyspace/screens/myPage.dart';
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:lottie/lottie.dart';


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

  //pdf
  PDFDocument doc;
  PDFDocument middle;
  bool _isPdfLoading = true;

  //이미지 크기
  double _scale = 1.0;
  double _previousScale = 1.0;

  _pdf() async {
    middle = await PDFDocument.fromURL(urls);
    print(middle);
    setState(() {
      doc = middle;
      _isPdfLoading = false;
    });
  }

  @override
  initState() {
    super.initState();
    initUser();
    // ignore: unnecessary_statements
    if (urls.contains('pdf'))
      _pdf();
  }


  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

  Future readText() async {
    print("누름");
    print(urls);
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFilePath(urls);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          print(word.text);
        }
      }
    }
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
                      onPressed: () =>
                      {
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(builder: (context) => Test()),
//                        )
                        _pdf()
                      },
                    ),
                    new IconButton(
                      icon: new Icon(Icons.record_voice_over),
                      tooltip: 'Hi!',
                      onPressed: () =>
                      {showAlertDialog(context)
                      },
                    ),
                    new IconButton(
                      icon: new Icon(Icons.headset),
                      tooltip: 'Text To Speech',
                      onPressed: () =>
                      {
                        readText()
                      },
                    )
                  ],
                ),
                body: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return (urls.contains('png'))
                          ? GestureDetector(
                          onScaleStart: (ScaleStartDetails details) {
                            print(details);
                            _previousScale = _scale;
                            setState(() {});
                          },
                          onScaleUpdate: (ScaleUpdateDetails details) {
                            print(details);
                            _scale = _previousScale * details.scale;
                            setState(() {});
                          },
                          onScaleEnd: (ScaleEndDetails details) {
                            print(details);

                            _previousScale = 1.0;
                            setState(() {});
                          },
                          child: RotatedBox(
                            quarterTurns: 0,
                            child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Transform(
                                  alignment: FractionalOffset.center,
                                  transform: Matrix4.diagonal3(
                                      Vector3(_scale, _scale, _scale)),
                                  child: Image.network(urls),
                                )),
                          ))
                          :
                      _isPdfLoading ?
                      Container(child: CircularProgressIndicator()) : Container(
                          height: 500.0,
                          width: 300.0,
                          child: PDFViewer(document: doc));
                    }),
                floatingActionButton: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Hexcolor('#7195C1'),
                    onPressed: () {
                      _reviewCountPlus();
                    },
                    child: StreamBuilder(
                        stream: getUsersFileListStreamSnapshots(context),
                        builder: (context, snapshot) {
                          print(urls);
                          var data = snapshot.data.documents[0];
                          var reviewCount = data['reviewCount'];
                          if (!snapshot.hasData)
                            return Center(child: CircularProgressIndicator());

                          return Container(child: Text('복습$reviewCount/5'));
                        })),
                floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat)));
  }

  //복습 다해서 firestore reviewCount 숫자 올리기
  void _reviewCountPlus() async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    var b;
    var a;

    //복습 횟수 가져오기
    await Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(file) //파일
        .collection("review")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => a = ('${f.data['reviewCount']}'));
      print(urls);
      print(a);
      b = int.parse(a);
      if (b < 5) b++;
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


  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('우주인에게 배운 내용을 설명해보세요.')),
          content:  Lottie.network(
              'https://assets7.lottiefiles.com/packages/lf20_Bu8wPm.json'),

          actions: <Widget>[
//            FlatButton(
//              child: Text('OK'),
//              onPressed: () {
//                Navigator.pop(context, "OK");
//              },
//            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, "닫기");
              },
            ),
          ],
        );
      },
    );
  }

}
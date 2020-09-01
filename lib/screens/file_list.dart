//행성 클릭하면 나오는 화면
//등록한 파일들을 리스트 형태로 보여줌

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//화면
import 'package:studyspace/screens/view_file.dart'; //파일 보는 화면
import 'package:studyspace/widget/widget.dart'; //스타일

class FileList extends StatefulWidget {
  FileList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FileListState createState() => _FileListState(title: title);
}

class _FileListState extends State<FileList> {
  String title; //행성 이름
  _FileListState({this.title});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final db = Firestore.instance;
  FirebaseUser user;
  String email;
  File _image; //추가 이미지
  String _imageURL; //추가 이미지 url

  List<String> urls = [];

  //파일이름 controller
  final _fileNamecontroller = TextEditingController();
  bool _validate = false; //텍스트필드 비어있는지 안 비어있는지 확인용

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

            body: Container(
//              child: StreamBuilder<QuerySnapshot>(
//                  stream: Firestore.instance.collection('files').document(user.uid).collection(title).document(_fileNamecontroller.text).collection('file').snapshots(),
//                  builder: (context, snapshot) {
//                    if (!snapshot.hasData)
//                      return Center(child: CircularProgressIndicator());
//                    return new ListView.builder(
//                      itemCount: snapshot.data.documents.length,
//                      itemBuilder: (BuildContext context, int index) =>
//                          buildFile(context, snapshot.data.documents[index]),
//                    );
//                  }),

              child: StreamBuilder(
                  stream: getUsersFileListStreamSnapshots(context),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                    return new ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) =>
                            buildFile(context, snapshot.data.documents[index]));
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Hexcolor('#7195C1'),
              onPressed: () {
                _modalBottomSheet(context);
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          )),
    );
  }

  //하단모달창
  void _modalBottomSheet(context) {
    showModalBottomSheet(
        elevation: 2.0,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
        builder: (BuildContext bc) {
          return Container(
            height: MediaQuery.of(bc).size.height * .50,
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('파일 이름', style: simpleTextStyle()),
                        Material(
                          //elevation: 2.0,
                          //borderRadius: BorderRadius.circular(10.0),
                          child: TextField(
                            controller: _fileNamecontroller,
                            decoration: InputDecoration(
                              hintText: '기억할 지식의 명칭 입력',
                              //hintStyle: f,
                              errorText:
                                  _validate ? '지식 이름을 꼭 채워주셔야 해욧!' : null,
                            ),
                          ),
                        ),
                        Text('파일 가져오기', style: simpleTextStyle()),
                        Row(
                          children: [
                            //카메라
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                onPressed: () {
                                  _getImage(ImageSource.camera, title);
                                },
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/icon/photographer.png'),
                                    Text('카메라'.toUpperCase(),
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                            //갤러리
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                onPressed: () {
                                  _getImage(ImageSource.gallery, title);
                                },
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/icon/picture.png'),
                                    Text('앨범'.toUpperCase(),
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                            //파일
                          ],
                        ),
                      ],
                    ),
                    //확인버튼
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                              child: Text('추가'),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              onPressed: () async {
                                //텍스트가 비어있는지 확인해서 _validate 변수 값 변경
                                //비어있으면 true, 채워있으면 flase
                                setState(() {
                                  _fileNamecontroller.text.isEmpty
                                      ? _validate = true
                                      : _validate = false;
                                });
                                if (_validate == false) {
//                                  final FirebaseUser user =
//                                      await _auth.currentUser();
                                  final uid = user.uid;
                                  _uploadFile(context, uid);
//                                  for (var i = 0; i <= urls.length; i++) {
//                                    await db
//                                        .collection("files")
//                                        .document(uid)
//                                        .collection(title)
//                                        .document(_controller.text)
//                                        .collection(i.toString())
//                                        .add({'url': urls[i]});
//                                    Navigator.pop(context);
//                                  }
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                )),
          );
        });
  }

  //이미지를 얻기
  void _getImage(ImageSource source, String title) async {
    File image = await ImagePicker.pickImage(
        source: source, maxWidth: 640, maxHeight: 480);
    if (image == null) return;

    //내가 선택한 이미지에 대한 정보가 _image에 저장됨
    setState(() {
      _image = image;
    });
  }

  Future _uploadFile(BuildContext context, String uid) async {
    print(uid);
    //스토리지에 업로드할 파일 경로
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('files')
        .child('${DateTime.now().millisecondsSinceEpoch}.png');

    //파일 업로드
    final task = firebaseStorageRef.putFile(
      _image,
      StorageMetadata(contentType: 'image/png'),
    );

    //파일 업로드 완료까지 대기
    final storageTaskSnapshot = await task.onComplete;

    //업로드한 사진의 url획득
    final downloadURL = await storageTaskSnapshot.ref.getDownloadURL();

    //firestore db에 저장
    //await를 이용해서 끝날 때까지 기다리기
    await Firestore.instance
        .collection("files")
        .document(uid)
        .collection(title) //
        .document(_fileNamecontroller.text)
        .collection('file')
        .add({
      'filename': _fileNamecontroller.text,
      'photoUrl': downloadURL,
      'uploadTime': DateTime.now()
    });
    Navigator.pop(context);

//    //업로드된 사진의 URL을 페이지에 반영
//    setState(() {
//      _imageURL = downloadURL;
//      print('url' + downloadURL);
//      urls.add(_imageURL);
//    });
  }

  Stream<QuerySnapshot> getUsersFileListStreamSnapshots(
      BuildContext context) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
        .collection("files")
        .document(uid)
        .collection(title)
        .document(_fileNamecontroller.text)
        .collection('file')
        .snapshots();

    print('snapshot');
//        .collection('userData')
//        .document(uid)
//        .collection('planets')
//        .snapshots();

//    .collection("files")
//        .document(uid)
//        .collection(title) //
//        .document(_fileNamecontroller.text)
//        .collection('file')
  }

  Widget _buildImage() {
    return _image == null
        ? Text('이미지가 없음')
        : Image.file(
            _image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
  }

  Widget buildFile(BuildContext context, DocumentSnapshot file) {
    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewFile(title: file['filename'], urls: file['photoUrl'])),
          );
        },
        child: Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          height: 50.0,
          width: 50.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(file['filename'])],
          )),
    ));
  }
}

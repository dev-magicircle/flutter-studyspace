//행성 클릭하면 나오는 화면
//등록한 파일들을 리스트 형태로 보여줌
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyspace/screens/home1.dart';
import 'package:studyspace/screens/myPage.dart';
import 'dart:io';
import 'package:android_alarm_manager/android_alarm_manager.dart';

//화면
import 'package:studyspace/screens/view_file.dart'; //파일 보는 화면
import 'package:studyspace/widget/widget.dart'; //스타일
import 'package:studyspace/screens/myPage.dart';
import 'package:studyspace/services/notificationManager.dart'; //알람

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

  bool _isImage = false; //이미지를 선택했는지 확인하는 bool변수

  //파일이름 controller
  final _fileNamecontroller = TextEditingController();
  bool _validate = false; //텍스트필드 비어있는지 안 비어있는지 확인용

  //filepicker
  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';



  @override
  initState() {
    super.initState();
    initUser();
    androidManager();
  }

  initUser() async {
    user = await _auth.currentUser();
    final uid = user.uid;

    setState(() {});
  }

  NotificationManager n = new NotificationManager(); //알람
  androidManager() async {
    await AndroidAlarmManager.initialize();
  }

  //푸시알림내용
  void notificate() {
    n.initNotificationManager();
    n.showNotificationWithDefaultSound("MyTitle", "Body");
    return;
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
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => (Home1())),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => (MyPage())),
                    );
                  },
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                child: StreamBuilder(
                    stream: getUsersFileListStreamSnapshots(context),
                    builder: (context, snapshot) {
                      if (snapshot.data == null)
                        return Container(child: Center(child: CircularProgressIndicator()));
                      else if (snapshot.hasError) {
                        return Text('${snapshot.error}',
                            style: TextStyle(color: Colors.black, fontSize: 12.0),
                            textAlign: TextAlign.justify);
                      }
                      return new ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildFile(
                                  context, snapshot.data.documents[index]));
                    }),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: null,
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
                        SizedBox(height:10.0),
                        Text('파일 가져오기', style: simpleTextStyle()),
                        SizedBox(height:10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.2,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                onPressed: () async {
                                  _isImage =
                                      false; //파일 선택했으므로 _isImage변수를 false로 바꿈
                                  file = await FilePicker.getFile();
                                  fileName = p.basename(file.path);
                                  setState(() {
                                    fileName = p.basename(file.path);
                                  });
                                  print(fileName);
                                },
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/icon/document.png'),
                                    Text('파일'.toUpperCase(),
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
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
                                AndroidAlarmManager.oneShotAt(
                                    DateTime.now().add(Duration(seconds: 20)),
                                    0,
                                    notificate,
                                    exact: true,
                                    allowWhileIdle: true,
                                    wakeup: true,
                                    rescheduleOnReboot: true,
                                    alarmClock: true);
                                //텍스트가 비어있는지 확인해서 _validate 변수 값 변경
                                //비어있으면 true, 채워있으면 flase
                                setState(() {
                                  _fileNamecontroller.text.isEmpty
                                      ? _validate = true
                                      : _validate = false;
                                });
                                if (_validate == false) {
                                  final uid = user.uid;
                                  _isImage
                                      ? _uploadImage(context, uid)
                                      : _uploadFile(context, uid);
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
    _isImage = true; //이미지를 선택했으므로 _isImage변수를 true로 바꿈
    File image = await ImagePicker.pickImage(
        source: source, maxWidth: 640, maxHeight: 480);
    if (image == null) return;

    //내가 선택한 이미지에 대한 정보가 _image에 저장됨
    setState(() {
      _image = image;
    });
  }

  Future _uploadImage(BuildContext context, String uid) async {
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
        .collection("file")
        .document(title)
        .collection('1')
        .add({

      'filename': _fileNamecontroller.text,
      'photoUrl': downloadURL,
      'uploadTime': DateTime.now(),
    });

    await Firestore.instance
        .collection("uploadTime")
        .document(uid)
        .collection("time")
        .add({
      'planetName':title,
      'filename': _fileNamecontroller.text,
      'photoUrl': downloadURL,
      'uploadTime': DateTime.now(),
    });

    //review에 복습 횟수 0으로 설정
    await Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(_fileNamecontroller.text) //파일
        .collection("review")
        .document("1")
        .setData({"reviewCount": int.parse('0')});
  }

  Future _uploadFile(BuildContext context, String uid) async {
    print(uid);
    //스토리지에 업로드할 파일 경로
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('files')
        .child('${DateTime.now().millisecondsSinceEpoch}.pdf');

    //파일 업로드
    final task = firebaseStorageRef.putFile(
      file,
      StorageMetadata(contentType: 'file/pdf'),
    );

    //파일 업로드 완료까지 대기
    final storageTaskSnapshot = await task.onComplete;

    //업로드한 파일의 url획득
    final downloadURL = await storageTaskSnapshot.ref.getDownloadURL();

    //firestore db에 저장
    //await를 이용해서 끝날 때까지 기다리기
    await Firestore.instance
        .collection("files")
        .document(uid)
    .collection("file")
        .document(title)
    .collection('1')
        .add({
      'filename': _fileNamecontroller.text,
      'photoUrl': downloadURL,
      'uploadTime': DateTime.now(),
    });

    //review에 복습 횟수 0으로 설정
    await Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(_fileNamecontroller.text) //파일
        .collection("review")
        .document("1")
        .setData({"reviewCount": int.parse('0')});
  }

  Stream<QuerySnapshot> getUsersFileListStreamSnapshots(
      BuildContext context) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
    .collection("files")
        .document(uid)
        .collection("file")
        .document(title)
        .collection('1')
        .snapshots();
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
                builder: (context) => ViewFile(
                    title: title,
                    file: file['filename'],
                    urls: file['photoUrl'])),
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
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 50.0,
              width: 50.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                child: Wrap(


                  children: [
                    Text(
                      file['filename'],
                    ),
                    StreamBuilder(
                        stream: getReviewCountStreamSnapshots(
                            context, file['filename']),
                        builder: (context, snapshot) {
                          if(snapshot.data == null) return CircularProgressIndicator();
                          var data = snapshot.data.documents[0];

                          var reviewCount = data['reviewCount'];

                          if ('$reviewCount' == '0')
                            return Container(child: Text('0%'));
                          else if ('$reviewCount' == '1')
                            return Row(children: [
                              Image.asset('assets/img/review1.png'),
                              SizedBox(width: 10.0),
                              Text('20%')
                            ]);
                          else if ('$reviewCount' == '2')
                            return Row(children: [
                              Image.asset('assets/img/review2.png'),
                              SizedBox(width: 10.0),
                              Text('40%')
                            ]);
                          else if ('$reviewCount' == '3')
                            return Row(children: [
                              Image.asset('assets/img/review4.png'),
                              SizedBox(width: 10.0),
                              Text('60%'),
                            ]);
                          else if ('$reviewCount' == '4')
                            return Row(children: [
                              Image.asset('assets/img/review5.png'),
                              SizedBox(width: 10.0),
                              Text('80%'),
                            ]);
                          else if ('$reviewCount' == '5')
                            return Row(children: [
                              Image.asset('assets/img/review5.png'),
                              SizedBox(width: 10.0),
                              Text('100%')
                            ]);
                          else
                            return Center(child: CircularProgressIndicator());
                        }),
                  ],
                ),
              )),
        ));
  }

  Stream<QuerySnapshot> getReviewCountStreamSnapshots(
      BuildContext context, String filename) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
        .collection("review")
        .document(uid)
        .collection(title) //행성이름
        .document(filename) //파일
        .collection("review")
        .snapshots();
  }




  String timestampToStrDateTime(Timestamp ts) {
    return DateTime.fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch)
        .toString();
  }

}

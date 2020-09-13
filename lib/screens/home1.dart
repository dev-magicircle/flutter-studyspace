import 'dart:math';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:studyspace/screens/file_list.dart';
import '../models/meeting.dart';

//화면
import 'package:studyspace/screens/calendar.dart'; //복습일정화면

import 'package:studyspace/screens/calendar1.dart'; //복습일정화면
import 'package:studyspace/screens/login.dart'; //로그인화면
import 'package:studyspace/screens/myPage.dart';
import 'package:studyspace/widget/widget.dart'; //스타일

class Home1 extends StatefulWidget {
  @override
  _Home1State createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  List<Meeting> meetings;
//  List colors = [Hexcolor('#7B73B5'), Hexcolor('#5E72C4'), Hexcolor('#7B779F')];
  Random random = new Random();
  List planetBackgroundImages = [
    "assets/img/planet_purple.png",
    "assets/img/planet_purpleGray.png",
    "assets/img/planet_blue.png"
  ];

  //칼라 랜덤하게 배정하기 위해서 random함수 이용
  int i = 0;

  void changeIndex() {
    setState(() => i = random.nextInt(3));
  }

//행성 이름 편집, 삭제용
  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();

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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.white,
        cursorColor: Colors.orange,
        fontFamily: 'Gmarket',
        textTheme: TextTheme(
          display2: TextStyle(
            fontFamily: '',
            fontSize: 14.0,
            color: Colors.white,
          ),
          button: TextStyle(),
        ),
      ),
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
              title: Text('STUDY SPACE', style: TextStyle(fontSize: 14.0)),
              centerTitle: true,
              actions: [
//                IconButton(icon: Icon(Icons.alarm_on), onPressed: null),
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
                    stream: getUsersPlanetsStreamSnapshots(context),
                    builder: (context, snapshot) {
                      print(planetBackgroundImages[i]);
                      if (!snapshot.hasData)
                        return Center(child: Text('우주가 비어있어요'));
                      return new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildPlanetCard(
                                  context, snapshot.data.documents[index],index));
                    }),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Hexcolor('#7195C1'),
              onPressed: () {
                changeIndex(); //칼라 랜덤하게 배정하기 위해서 숫자 랜덤
                print(i);
                _showDialog(context, _planetNamecontroller);
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Text('${user?.email}님'),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('마이페이지'),
                        ),
                      ],
                    ),
                    onTap: () {
                      print('push');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => (MyPage())),
                      );
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.alarm),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('알림 설정'),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('복습주기 설정'),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.alarm),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('복습 일정'),
                        ),
                      ],
                    ),
                    onTap: () async{
                     await _getData();
                     print('ddd');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => calendar1(meetings:meetings)),
                      );
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.help),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('앱 정보'),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.info),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('로그아웃'),
                        ),
                      ],
                    ),
                    onTap: () {
                      _auth.signOut().then((value) =>
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                              (route) => false));
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }

  //행성이름 팝업창
  _showDialog(context, _controller) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("새로운 행성 이름"),
              content: Container(
                height: 100.0,
                width: 400.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Material(
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(10.0),
                      child: TextField(
                          controller: _controller,
                          decoration:
                              textFieldInputDecoration("기억할 지식의 명칭 입력")),
                    ),
                    //확인버튼
                    Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                            child: Text('확인'),
                            color: Hexcolor('#7195C1'),
                            textColor: Colors.white,
                            onPressed: () async {
                              final FirebaseUser user =
                                  await _auth.currentUser();
                              final uid = user.uid;

                              await db
                                  .collection("planets")
                                  .document(uid)
                                  .collection("planet")
                                  .document(_controller.text)
                                  .setData({"planetName": _controller.text});

                                Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [],
            ));
  }

  Stream<QuerySnapshot> getUsersPlanetsStreamSnapshots(
      BuildContext context) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
        .collection("planets")
        .document(uid)
        .collection("planet")
//        .document(planet)
        .snapshots();
  }

  Widget buildPlanetCard(BuildContext context, DocumentSnapshot planet,num index) {
    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FileList(title: planet['planetName'])),
          );
        },
        //길게 누르면 편집 삭제 가능
        onLongPress: () {
          print('길게 눌렀땅');
          showUpdateOrDeleteDocDialog(planet);
        },
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                  child: Image.asset(planetBackgroundImages[i],
                      fit: BoxFit.cover)),
              Text(planet['planetName'], style: TextStyle(fontSize: 12.0))
            ],
          ),
          radius: 80.0,
          //child: Text(planet['name'],style:TextStyle(fontSize: 20.0))
        ));
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot planet) {
    _undNameCon.text = planet['name'];
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
//          title: Center(child: Text("행성을 삭제 하시겠습니까?")),
          content: Container(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: Text("행성을 삭제 하시겠습니까?")),
//                TextField(
//                  decoration: InputDecoration(labelText: "행성 이름"),
//                  controller: _undNameCon,
//                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () {
                _undNameCon.clear();
                Navigator.pop(context);
              },
            ),
//            FlatButton(
//              child: Text("편집"),
//              onPressed: () {
//                if (_undNameCon.text.isNotEmpty) {
//                  updateDoc(planet['Name'], _undNameCon.text);
//                }
//                Navigator.pop(context);
//              },
//            ),
            FlatButton(
              child: Text("삭제",style:TextStyle(color:Colors.red)),
              onPressed: () {
                deleteDoc(planet['planetName']);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
//
//  Future<void> updateDoc(String planet, String newName) async {
//    final FirebaseUser user = await _auth.currentUser();
//    final uid = user.uid;
//    Firestore.instance
//        .collection("userData")
//        .document(uid)
//        .collection("planets")
//        .document(planet)
//        .updateData({'name': newName});
//  }

  Future<void> deleteDoc(String planet) async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    //planets collection 안에 있는 행성 이름 제거
    Firestore.instance
        .collection("planets")
        .document(uid)
        .collection("planet")
        .document(planet)
        .delete();

    //files collection 안에 있는 행성 제거
    Firestore.instance
        .collection("files")
        .document(uid)
        .collection("file")
        .document(planet)
        .delete();

//    //review collection 안에 있는 행성 제거
//    Firestore.instance
//        .collection("review")
//        .document(uid)
//        .collection(planet).delete();
  }

  void _getData() async{
    meetings=List<Meeting>();
    print('d');
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    Firestore.instance.collection('uploadTime').document(uid).collection('time').snapshots() .listen((data) {
      for(int i=0;i<data.documents.length;i++){
      final DateTime today = data.documents[i].data['uploadTime'].toDate();
      final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
      final DateTime endTime = startTime.add(const Duration(hours: 1));
      final DateTime startTime1 = startTime.add(const Duration(days: 1));
      final DateTime startTime4 = startTime.add(const Duration(days: 4));
      final DateTime startTime7 = startTime.add(const Duration(days: 7));
      final DateTime startTime30 = startTime.add(const Duration(days: 30));
      final DateTime endTime1 = endTime.add(const Duration(days: 1));
      final DateTime endTime4 = endTime.add(const Duration(days: 4));
      final DateTime endTime7 = endTime.add(const Duration(days: 7));
      final DateTime endTime30 = endTime.add(const Duration(days: 30));
      meetings.add(Meeting(
        data.documents[i].data['planetName'],
          data.documents[i].data['filename'], startTime, endTime, const Color(0xFF0F8644), false));
      meetings.add(Meeting(
          data.documents[i].data['planetName'],data.documents[i].data['filename'], startTime1, endTime1, const Color(0xFF0F8644), false));
      meetings.add(Meeting(
          data.documents[i].data['planetName'],data.documents[i].data['filename'], startTime4, endTime4, const Color(0xFF0F8644), false));
      meetings.add(Meeting(
          data.documents[i].data['planetName'],data.documents[i].data['filename'], startTime7, endTime7, const Color(0xFF0F8644), false));
      meetings.add(Meeting(
          data.documents[i].data['planetName'], data.documents[i].data['filename'], startTime30, endTime30, const Color(0xFF0F8644), false));

    }}
      // DateTime today=
      //   meetings.add(Meeting(data.documents[0].data.filename,));
    );

  }

}


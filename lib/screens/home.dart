import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:studyspace/screens/file_list.dart';

//화면
import 'file:///C:/dev/studyspace/lib/screens/calendar.dart'; //복습일정화면
import 'package:studyspace/screens/login.dart'; //로그인화면
import 'package:studyspace/screens/myPage.dart';
import 'package:studyspace/widget/widget.dart'; //스타일

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List colors = [Hexcolor('#7B73B5'), Hexcolor('#5E72C4'), Hexcolor('#7B779F')];
  Random random = new Random();

  //칼라 랜덤하게 배정하기 위해서 random함수 이용
  int index = 0;

  void changeIndex() {
    setState(() => index = random.nextInt(3));
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  FirebaseUser user;
  String email;

  //행성 이름 편집, 삭제용
  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();

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
                      if (!snapshot.hasData)
                        return Center(child: Text('행성이 비어있어요'));
                      return new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildPlanetCard(
                                  context, snapshot.data.documents[index]));
                    }),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.add),
              backgroundColor: Hexcolor('#7195C1'),
              onPressed: () {
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
                          child: Text('알림 설'),
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
                          child: Text('복습'),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Calendar()),
                      );
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.info),
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
                child: Column(
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
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: FlatButton(
                        child: Text('확인'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                        onPressed: () async {
                          final FirebaseUser user = await _auth.currentUser();
                          final uid = user.uid;

                          await db
                              .collection("userData")
                              .document(uid)
                              .collection("planets")
                              .add({"name": _controller.text});
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Stream<QuerySnapshot> getUsersPlanetsStreamSnapshots(
      BuildContext context) async* {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;

    yield* Firestore.instance
        .collection('userData')
        .document(uid)
        .collection('planets')
        .snapshots();
  }

  Widget buildPlanetCard(BuildContext context, DocumentSnapshot planet) {
    return new GestureDetector(
        onTap: () {
          changeIndex(); //칼라 랜덤하게 배정하기 위해서 숫자 랜덤
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FileList(title: planet['name'])),
          );
        },
        //길게 누르면 편집 삭제 가능
        onDoubleTap: () {
          print('길게 눌렀땅');showUpdateOrDeleteDocDialog(planet);
        },
        child: CircleAvatar(
          //backgroundColor:colors[index],
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                  child: Image.asset("assets/img/planet_purple.png",
                      fit: BoxFit.cover)),
              Text(planet['name'], style: TextStyle(fontSize: 20.0))
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
          title: Text("Update/Delete Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: _undNameCon,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _undNameCon.clear();

                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Update"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty) {
                  updateDoc(planet['Name'], _undNameCon.text);
                }
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Delete"),
              onPressed: () {
                deleteDoc(planet['Name']);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> updateDoc(String planet, String newName) async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    Firestore.instance
        .collection("userData")
        .document(uid)
        .collection("planets")
        .document(planet)
        .updateData({'Name': newName});
  }

  Future<void> deleteDoc(String planet) async {
    final FirebaseUser user = await _auth.currentUser();
    final uid = user.uid;
    Firestore.instance
        .collection("userData")
        .document(uid)
        .collection("planets")
        .document(planet)
        .delete();
  }
}

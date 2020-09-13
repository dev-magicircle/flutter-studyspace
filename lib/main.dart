import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyspace/screens/home1.dart';
import 'file:///C:/dev/studyspace/lib/screens/home.dart'; //홈화면
import 'package:studyspace/screens/login.dart'; //로그인화면

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.white,
        cursorColor: Colors.orange,
        fontFamily:'Gmarket',
        textTheme: TextTheme(
          display2: TextStyle(
            fontFamily: '',
            fontSize: 45.0,
            color: Colors.white,
          ),
          button: TextStyle(
          ),
        ),
      ),
      home: MyAppPage(title: 'Study Space'),
    );
  }
}

class MyAppPage extends StatefulWidget {
  MyAppPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  @override
  Widget build(BuildContext context) {
    checkUserAlreadyLogin().then((isLogin) {
      if (isLogin == true) {
        print('이미 로그인');
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Home1()), (route) => false);
      } else {
        print('로그인X');
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (route) => false);
      }
    });
    return new Scaffold(
        body: Card(
            child: Center(
                child: Text('로딩...',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo)))));
  }
}

checkUserAlreadyLogin() async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  return _auth
      .currentUser()
      .then((user) => user != null ? true : false)
      .catchError((onError) => false);
}

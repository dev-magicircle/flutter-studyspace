import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'file:///C:/dev/studyspace/lib/screens/home.dart';
import 'package:studyspace/screens/home1.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Study Space',
      // logo:'assets/img/logo.png',
      //로그인
      onLogin: _loginUser,
      //회원가입
      onSignup: _signUpUser,
      onSubmitAnimationCompleted: () async {
        FirebaseAuth _auth = FirebaseAuth.instance;
        //로그인이 돼있으면 Home화면으로 가고 안돼있으면 toast메세지가 나온다.
        await _auth.currentUser().then((user) => user != null
            ? Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Home1()))
            : Fluttertoast.showToast(msg: "로그인 정보가 없습니다."));
      },
      onRecoverPassword: _recoveryPassword,
    );
  }

  //로그인
  Future<String> _loginUser(LoginData loginData) {
    _handleSignIn(loginData.name.trim(), loginData.password)
        .then((user) => Fluttertoast.showToast(
            msg: "환영합니다 ${user.email}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.teal,
            textColor: Colors.white,
            fontSize: 16))
        .catchError((e) => Fluttertoast.showToast(
            msg: "${e}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
  }

  Future<FirebaseUser> _handleSignIn(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser _user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    return _user;
  }

  Future<String> _signUpUser(LoginData loginData) {
    _handleSignUp(loginData.name.trim(), loginData.password).then((user) =>
        Fluttertoast.showToast(
            msg: "환영합니다 ${user.email}님",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.teal,
            textColor: Colors.white,
            fontSize: 16));
  }

  Future<FirebaseUser> _handleSignUp(String email, String password) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser _user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;
    return _user;
  }

  //회원가입
  Future<String> _recoveryPassword(String email) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.sendPasswordResetEmail(email: email).catchError((e) =>
        Fluttertoast.showToast(
            msg: "${e}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16));
  }
}

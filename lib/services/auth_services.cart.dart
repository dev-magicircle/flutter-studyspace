import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //UID get
Future<String> getCurrentUID() async{
  return (await _firebaseAuth.currentUser()).uid;

}
}
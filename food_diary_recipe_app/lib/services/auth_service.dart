import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return user.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return user.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user => _auth.authStateChanges();
}

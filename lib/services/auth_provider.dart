import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user;
      } else {
        _isLoggedIn = false;
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    UserCredential? userCredential = await AuthService().signInWithGoogle();
    _isLoggedIn = true;
    _currentUser = userCredential?.user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}

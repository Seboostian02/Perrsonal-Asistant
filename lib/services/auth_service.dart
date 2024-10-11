import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/calendar',
  ]);

  GoogleSignInAccount? _googleUser;
  GoogleSignInAuthentication? _googleAuth;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      _googleUser = await _googleSignIn.signIn();
      _googleAuth = await _googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: _googleAuth?.accessToken,
        idToken: _googleAuth?.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("User signed in: ${userCredential.user?.displayName}");
      print("------------------");
      return userCredential;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<String?> get accessToken async {
    if (_googleAuth == null) {
      await signInWithGoogle();
    }
    return _googleAuth?.accessToken;
  }
}

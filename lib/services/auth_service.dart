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

      if (_googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: _googleAuth?.accessToken,
          idToken: _googleAuth?.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        print("User signed in: ${userCredential.user?.displayName}");
        print("---------------------------");
        return userCredential;
      } else {
        print("Google sign-in canceled by user.");
        print("---------------------------");
        return null;
      }
    } catch (e) {
      print("Error signing in: $e");
      print("---------------------------");
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

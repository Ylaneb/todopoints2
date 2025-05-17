// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Returns the currently signed-in user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Sign in with Google (web & mobile).
  static Future<UserCredential> signInWithGoogle() async {
    // On web you may need the clientId here; add it if you get a meta-tag error.
    final googleSignIn = GoogleSignIn(
      scopes: ['email'],  // only request email scope to avoid People API calls
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign-in aborted by user');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  /// Sign out from both Google and Firebase.
  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}

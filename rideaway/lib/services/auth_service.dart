import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. Sign Up — throws descriptive error on failure
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    } catch (e) {
      debugPrint("Sign Up Error: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  // 2. Login — throws descriptive error on failure
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    } catch (e) {
      debugPrint("Login Error: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  // 3. Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      throw Exception("Google Sign-In failed. Please try again.");
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Map Firebase error codes to user-friendly messages
  Exception _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return Exception("No account found with this email.");
      case 'wrong-password':
        return Exception("Incorrect password. Please try again.");
      case 'email-already-in-use':
        return Exception("This email is already registered.");
      case 'weak-password':
        return Exception("Password is too weak. Use at least 6 characters.");
      case 'invalid-email':
        return Exception("Please enter a valid email address.");
      case 'user-disabled':
        return Exception("This account has been disabled.");
      case 'too-many-requests':
        return Exception("Too many attempts. Please try again later.");
      case 'invalid-credential':
        return Exception("Invalid email or password.");
      default:
        return Exception("Authentication failed. Please try again.");
    }
  }
}

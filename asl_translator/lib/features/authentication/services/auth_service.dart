import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../utils/helpers/secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      bool rememberMe,
      ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (rememberMe) {
        await SecureStorage.saveCredentials(email, password, true);
      } else {
        await SecureStorage.clearCredentials();
      }

      return credential;
    } catch (e) {
      await SecureStorage.clearCredentials();
      throw _getErrorMessage(e.toString());
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // First check if email exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw 'email-already-in-use';
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.sendEmailVerification();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    }
  }

  Future<void> signOut() async {
    final rememberMe = await SecureStorage.getRememberMeStatus();
    if (!rememberMe) {
      await SecureStorage.clearCredentials();
    }
    await _auth.signOut();
  }

  Future<bool> hasStoredCredentials() async {
    final credentials = await SecureStorage.getCredentials();
    return credentials['email'] != null &&
        credentials['password'] != null;
  }

  Future<bool> tryAutoLogin() async {
    final credentials = await SecureStorage.getCredentials();
    if (credentials['email'] != null &&
        credentials['password'] != null &&
        credentials['remember_me'] == 'true') {
      try {
        await signInWithEmailAndPassword(
          credentials['email']!,
          credentials['password']!,
          true,
        );
        return true;
      } catch (e) {
        await SecureStorage.clearCredentials();
        return false;
      }
    }
    return false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _getErrorMessage(e.toString());
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An error occurred: $code';
    }
  }
}

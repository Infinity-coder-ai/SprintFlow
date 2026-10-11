import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update online status
      if (credential.user != null) {
        await FirebaseService.updateOnlineStatus(credential.user!.uid, true);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = AppConstants.errorUserNotFound;
          break;
        case 'wrong-password':
          message = AppConstants.errorInvalidCredentials;
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'User account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later';
          break;
        default:
          message = 'Authentication failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw AuthException('Please enter your email address');
    }
    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email address. Please check the spelling or create an account first.';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          message =
              'Too many attempts. Please wait a few minutes and try again.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your connection and try again.';
          break;
        case 'operation-not-allowed':
          message =
              'Password reset is not enabled. Please contact support.';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Best-effort verification email to the currently signed-in user.
  // Never blocks registration; the user can resend from the verify screen.
  static Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Verification email not sent: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseService.updateOnlineStatus(user.uid, false);
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  /// Machine-readable Firebase code (e.g. 'email-already-in-use'), if any.
  final String code;

  AuthException(this.message, {this.code = ''});

  @override
  String toString() => message;
}

/// Maps Firebase registration failures to user-facing messages.
String registrationErrorMessage(FirebaseAuthException e, String operation) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'An account with this email already exists. Please sign in instead — you can resend the verification link from there if needed.';
    case 'weak-password':
      return 'Password is too weak';
    case 'invalid-email':
      return 'Invalid email address';
    default:
      return '$operation: ${e.message}';
  }
}

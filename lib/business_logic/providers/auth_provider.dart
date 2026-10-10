import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/models/user_model.dart';
import '../../database/services/auth_permissions.dart';
import '../../database/services/auth_registration.dart';
import '../../database/services/auth_service.dart';
import '../../database/services/firebase_service.dart';
import '../../database/services/pending_registration_service.dart';
import '../../core/constants/app_constants.dart';

part 'auth_provider.registration.dart';
part 'auth_provider.management.dart';
part 'auth_provider.verification.dart';

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;
  bool _emailVerified = false;
  String? _pendingEmail;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isManager => _userData?.isManager ?? false;
  bool get isEmployee => _userData?.isEmployee ?? false;
  bool get isClient => _userData?.isClient ?? false;
  bool get isEmailVerified => _emailVerified;
  bool get hasPendingRegistration => _pendingEmail != null;
  String? get pendingEmail => _pendingEmail;

  // Initialize auth state listener
  void initialize() {
    _isLoading = true;
    _clearError();
    FirebaseService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userData = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _pendingEmail = null;
      final userData = await FirebaseService.getUserData(userId);
      if (userData != null) {
        _userData = userData;
        await FirebaseService.updateOnlineStatus(userId, true);
        await refreshEmailVerified();
        return;
      }

      final resolved = await resolveUserRecord(userId);
      if (resolved != null) {
        _userData = resolved;
        await FirebaseService.updateOnlineStatus(userId, true);
        return;
      }
      if (_pendingEmail == null) {
        _setError('This email is not registered.');
      }
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      _pendingEmail = null;

      final cred = await AuthService.signInWithEmailAndPassword(
        email.trim().toLowerCase(),
        password,
      );
      if (cred.user == null) {
        _setError('Invalid credentials');
        return false;
      }

      final userDoc = await FirebaseService.getUserData(cred.user!.uid);
      if (userDoc == null) {
        final resolved = await resolveUserRecord(cred.user!.uid);
        if (resolved != null) {
          _userData = resolved;
          await FirebaseService.updateOnlineStatus(cred.user!.uid, true);
          return true;
        }
        if (_pendingEmail == null) {
          await AuthService.signOut();
          _setError('This email does not exist in the system.');
          return false;
        }
        // Verified link pending: stay signed in so the user can resend.
        return true;
      }

      final validRoles = {
        AppConstants.roleManager,
        AppConstants.roleEmployee,
        AppConstants.roleClient,
      };

      if (!validRoles.contains(userDoc.role)) {
        await AuthService.signOut();
        _setError('Account role is invalid. Please contact the administrator.');
        return false;
      }

      _userData = userDoc;
      await FirebaseService.updateOnlineStatus(cred.user!.uid, true);
      await refreshEmailVerified();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _firebaseUser = null;
      _userData = null;
      _pendingEmail = null;
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}

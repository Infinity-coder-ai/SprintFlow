import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isManager => _userData?.isManager ?? false;
  bool get isEmployee => _userData?.isEmployee ?? false;
  bool get isClient => _userData?.isClient ?? false;

  // Initialize auth state listener
  void initialize() {
    FirebaseService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userData = null;
        _isLoading = false; // ensure UI can move off splash
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final userData = await FirebaseService.getUserData(userId);
      if (userData != null) {
        _userData = userData;
        await FirebaseService.updateOnlineStatus(userId, true);
      } else {
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
      
      final cred = await AuthService.signInWithEmailAndPassword(email, password);
      if (cred.user == null) {
        _setError('Invalid credentials');
        return false;
      }
      // Require a Firestore profile to exist; if missing, sign out and show message
      final userDoc = await FirebaseService.getUserData(cred.user!.uid);
      if (userDoc == null) {
        await AuthService.signOut();
        _setError('This email does not exist.');
        return false;
      }
      _userData = userDoc;
      await FirebaseService.updateOnlineStatus(cred.user!.uid, true);
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

  // Create manager account
  Future<bool> createManagerAccount(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.createManagerAccount(email, password, name);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create employee account (for managers)
  Future<bool> createEmployeeAccount(
    String email, 
    String password, 
    String name,
    {String? department, String? position}
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_userData == null || !_userData!.isManager) {
        _setError('Only managers can create employee accounts');
        return false;
      }
      
      await AuthService.createEmployeeAccount(
        email, 
        password, 
        name, 
        _userData!.id,
        department: department,
        position: position,
      );
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Employee creation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create employee account (self-registration)
  Future<bool> createEmployeeAccountSelf(
    String email, 
    String password, 
    String name,
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.createEmployeeAccountSelf(
        email, 
        password, 
        name,
      );
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Employee registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create client account (for managers)
  Future<bool> createClientAccount(
    String email, 
    String password, 
    String name,
    {String? companyName, String? contactPerson}
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_userData == null || !_userData!.isManager) {
        _setError('Only managers can create client accounts');
        return false;
      }
      
      await AuthService.createClientAccount(
        email, 
        password, 
        name, 
        _userData!.id,
        companyName: companyName,
        contactPerson: contactPerson,
      );
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Client creation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create client account (self-registration)
  Future<bool> createClientAccountSelf(
    String email,
    String password,
    String name,
    {String? companyName, String? contactPerson}
  ) async {
    try {
      _setLoading(true);
      _clearError();
      await AuthService.createClientAccountSelf(
        email,
        password,
        name,
        companyName: companyName,
        contactPerson: contactPerson,
      );
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Client registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Password reset failed: $e');
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
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_userData == null) {
        _setError('No user data available');
        return false;
      }
      
      await AuthService.updateProfile(_userData!.id, data);
      
      // Reload user data
      await _loadUserData(_userData!.id);
      return true;
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check permissions
  Future<bool> hasPermission(String permission) async {
    if (_userData == null) return false;
    
    try {
      return await AuthService.hasPermission(_userData!.id, permission);
    } catch (e) {
      return false;
    }
  }

  // Validate role
  Future<bool> validateRole(List<String> allowedRoles) async {
    if (_userData == null) return false;
    
    try {
      return await AuthService.validateRole(_userData!.id, allowedRoles);
    } catch (e) {
      return false;
    }
  }

  // Check if can manage user
  Future<bool> canManageUser(String targetUserId) async {
    if (_userData == null) return false;
    
    try {
      return await AuthService.canManageUser(_userData!.id, targetUserId);
    } catch (e) {
      return false;
    }
  }

  // Delete user account (for managers)
  Future<bool> deleteUserAccount(String targetUserId) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_userData == null || !_userData!.isManager) {
        _setError('Only managers can delete user accounts');
        return false;
      }
      
      await AuthService.deleteUserAccount(targetUserId, _userData!.id);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('User deletion failed: $e');
      return false;
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

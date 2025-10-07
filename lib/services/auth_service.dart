import 'package:firebase_auth/firebase_auth.dart';
 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update online status
      if (credential.user != null) {
        await FirebaseService.updateOnlineStatus(
          credential.user!.uid, 
          true
        );
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

  // Create account for managers (only managers can self-register)
  static Future<UserCredential> createManagerAccount(
    String email, 
    String password, 
    String name
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: AppConstants.roleManager,
          createdAt: DateTime.now(),
        );
        
        await FirebaseService.createUserDocument(user);
        await FirebaseService.updateOnlineStatus(credential.user!.uid, true);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Create employee account (only managers can create employees)
  static Future<UserCredential> createEmployeeAccount(
    String email, 
    String password, 
    String name,
    String managerId,
    {String? department, String? position}
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: AppConstants.roleEmployee,
          managerId: managerId,
          department: department,
          position: position,
          hireDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        
        await FirebaseService.createUserDocument(user);
        
        // Update manager's managed employees list
        await FirebaseService.updateUserDocument(managerId, {
          'managedEmployees': FieldValue.arrayUnion([credential.user!.uid])
        });
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Employee creation failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Create employee account using the existing Firebase instance
  static Future<UserCredential> createEmployeeAccountSecondary(
    String email,
    String password,
    String name,
    String managerId,
    {String? department, String? position}
  ) async {
    try {
      // Use the existing Firebase instance instead of creating a secondary one
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email,
        name: name,
        role: AppConstants.roleEmployee,
        managerId: managerId,
        department: department,
        position: position,
        hireDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await FirebaseService.createUserDocument(user);
      await FirebaseService.updateUserDocument(managerId, {
        'managedEmployees': FieldValue.arrayUnion([uid])
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Employee creation failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Create employee account (self-registration)
  static Future<UserCredential> createEmployeeAccountSelf(
    String email,
    String password,
    String name,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email,
        name: name,
        role: AppConstants.roleEmployee,
        createdAt: DateTime.now(),
      );
      await FirebaseService.createUserDocument(user);
      return cred;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Employee registration failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Create client account (only managers can invite clients)
  static Future<UserCredential> createClientAccount(
    String email, 
    String password, 
    String name,
    String managerId,
    {String? companyName, String? contactPerson}
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user document in Firestore
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: AppConstants.roleClient,
          companyName: companyName,
          contactPerson: contactPerson,
          createdAt: DateTime.now(),
        );
        
        await FirebaseService.createUserDocument(user);
        
        // Update manager's managed clients list
        await FirebaseService.updateUserDocument(managerId, {
          'managedClients': FieldValue.arrayUnion([credential.user!.uid])
        });
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Client creation failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Create client account (self-registration)
  static Future<UserCredential> createClientAccountSelf(
    String email,
    String password,
    String name,
    {String? companyName, String? contactPerson}
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email,
        name: name,
        role: AppConstants.roleClient,
        companyName: companyName,
        contactPerson: contactPerson,
        createdAt: DateTime.now(),
      );
      await FirebaseService.createUserDocument(user);
      return cred;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Client registration failed: ${e.message}';
      }
      throw AuthException(message);
    }
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw AuthException(message);
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
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get current user data
  static Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await FirebaseService.getUserData(user.uid);
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // Check if user has permission to access
  static Future<bool> hasPermission(String userId, String permission) async {
    try {
      final userData = await FirebaseService.getUserData(userId);
      if (userData == null) return false;

      switch (permission) {
        case 'create_employees':
          return userData.isManager;
        case 'create_clients':
          return userData.isManager;
        case 'manage_projects':
          return userData.isManager;
        case 'view_projects':
          return true; // All authenticated users can view their projects
        case 'create_tasks':
          return userData.isManager;
        case 'update_tasks':
          return userData.isManager || userData.isEmployee;
        default:
          return false;
      }
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Validate user role for specific action
  static Future<bool> validateRole(String userId, List<String> allowedRoles) async {
    try {
      final userData = await FirebaseService.getUserData(userId);
      if (userData == null) return false;
      
      return allowedRoles.contains(userData.role);
    } catch (e) {
      print('Error validating role: $e');
      return false;
    }
  }

  // Check if user can manage another user
  static Future<bool> canManageUser(String managerId, String targetUserId) async {
    try {
      final managerData = await FirebaseService.getUserData(managerId);
      if (managerData == null || !managerData.isManager) return false;

      final targetUserData = await FirebaseService.getUserData(targetUserId);
      if (targetUserData == null) return false;

      // Managers can manage employees and clients they created
      if (targetUserData.isEmployee || targetUserData.isClient) {
        return targetUserData.managerId == managerId;
      }

      return false;
    } catch (e) {
      print('Error checking management permissions: $e');
      return false;
    }
  }

  // Update user profile
  static Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await FirebaseService.updateUserDocument(userId, data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Delete user account (only managers can delete their managed users)
  static Future<void> deleteUserAccount(String userId, String managerId) async {
    try {
      // Check if manager can delete this user
      final canDelete = await canManageUser(managerId, userId);
      if (!canDelete) {
        throw AuthException('You do not have permission to delete this user');
      }

      // Delete user document from Firestore
      await FirebaseService.firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .delete();

      // Delete Firebase Auth user
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => message;
}

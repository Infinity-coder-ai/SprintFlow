import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'pending_registration_service.dart';

/// Account creation flows (manager-created and self-registered accounts).
class AuthRegistration {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create account for managers (only managers can self-register)
  static Future<UserCredential> createManagerAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          email: email.trim().toLowerCase(),
          name: name,
          role: AppConstants.roleManager,
          createdAt: DateTime.now(),
        );

        // Staged in pending_users until the email is verified.
        await PendingRegistrationService.savePending(user);
        await FirebaseService.updateOnlineStatus(credential.user!.uid, true);
        await AuthService.sendVerificationEmail();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        registrationErrorMessage(e, 'Registration failed'),
        code: e.code,
      );
    }
  }

  // Create employee account (only managers can create employees)
  static Future<UserCredential> createEmployeeAccount(
    String email,
    String password,
    String name,
    String managerId, {
    String? department,
    String? position,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          email: email.trim().toLowerCase(),
          name: name,
          role: AppConstants.roleEmployee,
          managerId: managerId,
          department: department,
          position: position,
          hireDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Staged in pending_users until the email is verified.
        await PendingRegistrationService.savePending(user);

        // Update manager's managed employees list
        await FirebaseService.updateUserDocument(managerId, {
          'managedEmployees': FieldValue.arrayUnion([credential.user!.uid])
        });
        await AuthService.sendVerificationEmail();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        registrationErrorMessage(e, 'Employee creation failed'),
        code: e.code,
      );
    }
  }

  // Create employee account (self-registration)
  static Future<UserCredential> createEmployeeAccountSelf(
    String email,
    String password,
    String name,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email.trim().toLowerCase(),
        name: name,
        role: AppConstants.roleEmployee,
        createdAt: DateTime.now(),
      );
      // No database record yet: profile waits in pending_users until
      // the email is verified.
      await PendingRegistrationService.savePending(user);
      await AuthService.sendVerificationEmail();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        registrationErrorMessage(e, 'Employee registration failed'),
        code: e.code,
      );
    }
  }

  // Create client account (only managers can invite clients)
  static Future<UserCredential> createClientAccount(
    String email,
    String password,
    String name,
    String managerId, {
    String? companyName,
    String? contactPerson,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          email: email.trim().toLowerCase(),
          name: name,
          role: AppConstants.roleClient,
          companyName: companyName,
          contactPerson: contactPerson,
          createdAt: DateTime.now(),
        );

        // Staged in pending_users until the email is verified.
        await PendingRegistrationService.savePending(user);

        // Update manager's managed clients list
        await FirebaseService.updateUserDocument(managerId, {
          'managedClients': FieldValue.arrayUnion([credential.user!.uid])
        });
        await AuthService.sendVerificationEmail();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        registrationErrorMessage(e, 'Client creation failed'),
        code: e.code,
      );
    }
  }

  // Create client account (self-registration)
  static Future<UserCredential> createClientAccountSelf(
    String email,
    String password,
    String name, {
    String? companyName,
    String? contactPerson,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid,
        email: email.trim().toLowerCase(),
        name: name,
        role: AppConstants.roleClient,
        companyName: companyName,
        contactPerson: contactPerson,
        createdAt: DateTime.now(),
      );
      // No database record yet: profile waits in pending_users until
      // the email is verified.
      await PendingRegistrationService.savePending(user);
      await AuthService.sendVerificationEmail();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        registrationErrorMessage(e, 'Client registration failed'),
        code: e.code,
      );
    }
  }
}

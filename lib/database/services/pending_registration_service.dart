import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

/// Signup profiles waiting for email verification.
///
/// Nothing is written to `users` until the address is verified, so stale
/// or mistyped emails can never populate the database. Rules allow only
/// the owner to read/write/delete their own pending doc (no index needed:
/// single-document reads/writes only).
class PendingRegistrationService {
  static CollectionReference<Map<String, dynamic>> get _pending =>
      FirebaseService.firestore.collection('pending_users');

  /// Stores the signup profile under the new auth user's own uid.
  static Future<void> savePending(UserModel user) async {
    await _pending.doc(user.id).set(user.toFirestore());
  }

  /// Returns the raw pending profile, or null when there is none.
  static Future<Map<String, dynamic>?> getPending(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final doc = await _pending.doc(userId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  /// Deletes a pending profile (owner only, per rules).
  static Future<void> deletePending(String userId) async {
    try {
      await _pending.doc(userId).delete();
    } catch (_) {}
  }

  /// Moves a verified pending signup into `users` and clears the pending
  /// doc. Returns the created user, or null when there is nothing to
  /// migrate. Callers must check email verification first.
  static Future<UserModel?> migrateToUsers(String userId) async {
    final data = await getPending(userId);
    if (data == null) return null;

    final user = UserModel(
      id: userId,
      email: (data['email'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      role: (data['role'] ?? AppConstants.roleEmployee) as String,
      managerId: data['managerId'] as String?,
      department: data['department'] as String?,
      position: data['position'] as String?,
      companyName: data['companyName'] as String?,
      companyLogo: data['companyLogo'] as String?,
      contactPerson: data['contactPerson'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );

    await FirebaseService.createUserDocument(user);
    await deletePending(userId);
    return await FirebaseService.getUserData(userId) ?? user;
  }
}

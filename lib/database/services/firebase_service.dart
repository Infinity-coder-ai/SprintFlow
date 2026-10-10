import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Get user stream
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Get user ID
  static String? get userId => currentUser?.uid;

  // Get user email
  static String? get userEmail => currentUser?.email;

  // Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Find the user document in the canonical users collection.
  // Legacy role-scoped user collections are no longer used.
  static Future<DocumentSnapshot?> findUserDocument(String userId) async {
    try {
      final userDoc =
          await firestore
              .collection(AppConstants.collectionUsers)
              .doc(userId)
              .get();

      return userDoc.exists ? userDoc : null;
    } catch (e) {
      debugPrint('Error finding user document: $e');
      return null;
    }
  }

  // Get user document from the canonical users collection.
  static Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await findUserDocument(userId);
      if (doc == null) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Delete a user document from the canonical users collection.
  // Auth-user deletion should be handled by a trusted backend/admin flow.
  static Future<void> deleteUserDocument(String userId) async {
    final doc = await findUserDocument(userId);
    if (doc == null) {
      throw Exception('User not found');
    }

    await doc.reference.delete();
  }

  // Create user document in the canonical users collection.
  static Future<void> createUserDocument(UserModel user) async {
    try {
      await firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  // Update user document in the canonical users collection.
  static Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final doc = await findUserDocument(userId);
      if (doc == null) {
        throw Exception('User not found');
      }

      await doc.reference.update(data);
    } catch (e) {
      debugPrint('Error updating user document: $e');
      rethrow;
    }
  }

  // Get user by email from the canonical users collection only.
  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query =
          await firestore
              .collection(AppConstants.collectionUsers)
              .where('email', isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  // Get users by role from the canonical users collection.
  static Stream<List<UserModel>> getUsersByRole(String role) {
    return firestore
        .collection(AppConstants.collectionUsers)
        .where('role', isEqualTo: role)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Get managed users (for managers) from the canonical users collection.
  static Stream<List<UserModel>> getManagedUsers(String managerId) {
    return firestore
        .collection(AppConstants.collectionUsers)
        .where('managerId', isEqualTo: managerId)
        .where('role', isEqualTo: AppConstants.roleEmployee)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Update user online status (searches across all role collections)
  static Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      final doc = await findUserDocument(userId);
      if (doc == null) return;

      await doc.reference.update({
        'isOnline': isOnline,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }
}

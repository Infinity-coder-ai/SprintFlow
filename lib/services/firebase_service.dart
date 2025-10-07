import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

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

  // Get user document from Firestore (searches across all role collections)
  static Future<UserModel?> getUserData(String userId) async {
    try {
      // Search in all role collections
      final collections = [
        AppConstants.collectionManagers,
        AppConstants.collectionEmployees,
        AppConstants.collectionClients,
        AppConstants.collectionUsers, // fallback
      ];
      
      for (final collection in collections) {
        final doc = await firestore
            .collection(collection)
            .doc(userId)
            .get();
        
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Create user document in role-scoped collection
  static Future<void> createUserDocument(UserModel user) async {
    try {
      String collectionName;
      switch (user.role) {
        case AppConstants.roleManager:
          collectionName = AppConstants.collectionManagers;
          break;
        case AppConstants.roleEmployee:
          collectionName = AppConstants.collectionEmployees;
          break;
        case AppConstants.roleClient:
          collectionName = AppConstants.collectionClients;
          break;
        default:
          collectionName = AppConstants.collectionUsers; // fallback
      }
      
      await firestore
          .collection(collectionName)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  // Upsert employee by email: if not found, create a new employee account placeholder
  static Future<UserModel> upsertEmployeeByEmail({
    required String managerId,
    required String email,
    String name = 'Employee',
  }) async {
    // Try to find user by email
    final existing = await getUserByEmail(email);
    if (existing != null) {
      if (!existing.isEmployee) {
        // convert role to employee if needed
        await updateUserDocument(existing.id, {'role': AppConstants.roleEmployee, 'managerId': managerId});
      }
      return existing;
    }

    // Create a placeholder employee profile (Auth creation can be done later by manager invite)
    final docRef = firestore.collection(AppConstants.collectionEmployees).doc();
    final newUser = UserModel(
      id: docRef.id,
      email: email,
      name: name,
      role: AppConstants.roleEmployee,
      managerId: managerId,
      createdAt: DateTime.now(),
      isActive: true,
    );
    await docRef.set(newUser.toFirestore());
    return newUser;
  }

  // Update user document (searches across all role collections)
  static Future<void> updateUserDocument(String userId, Map<String, dynamic> data) async {
    try {
      // Search in all role collections to find the user
      final collections = [
        AppConstants.collectionManagers,
        AppConstants.collectionEmployees,
        AppConstants.collectionClients,
        AppConstants.collectionUsers, // fallback
      ];
      
      for (final collection in collections) {
        try {
          final doc = await firestore
              .collection(collection)
              .doc(userId)
              .get();
          
          if (doc.exists) {
            // Found the user, update in this collection
            await firestore
                .collection(collection)
                .doc(userId)
                .update(data);
            return;
          }
        } catch (e) {
          // Continue to next collection if this one fails
          print('Error searching collection $collection: $e');
        }
      }
      throw Exception('User not found in any collection');
    } catch (e) {
      print('Error updating user document: $e');
      rethrow;
    }
  }

  // Check if user exists in Firestore
  static Future<bool> userExists(String userId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Get user by email (searches across all role collections)
  static Future<UserModel?> getUserByEmail(String email) async {
    try {
      // Search in all role collections
      final collections = [
        AppConstants.collectionManagers,
        AppConstants.collectionEmployees,
        AppConstants.collectionClients,
        AppConstants.collectionUsers, // fallback
      ];
      
      for (final collection in collections) {
        try {
          final query = await firestore
              .collection(collection)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          
          if (query.docs.isNotEmpty) {
            return UserModel.fromFirestore(query.docs.first);
          }
        } catch (e) {
          // Continue to next collection if this one fails
          print('Error searching collection $collection: $e');
        }
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Get users by role (uses role-scoped collections)
  static Stream<List<UserModel>> getUsersByRole(String role) {
    String collectionName;
    switch (role) {
      case AppConstants.roleManager:
        collectionName = AppConstants.collectionManagers;
        break;
      case AppConstants.roleEmployee:
        collectionName = AppConstants.collectionEmployees;
        break;
      case AppConstants.roleClient:
        collectionName = AppConstants.collectionClients;
        break;
      default:
        collectionName = AppConstants.collectionUsers; // fallback
    }
    
    return firestore
        .collection(collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Get managed users (for managers) - searches employees collection
  static Stream<List<UserModel>> getManagedUsers(String managerId) {
    return firestore
        .collection(AppConstants.collectionEmployees)
        .where('managerId', isEqualTo: managerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Update user online status (searches across all role collections)
  static Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      // Search in all role collections to find the user
      final collections = [
        AppConstants.collectionManagers,
        AppConstants.collectionEmployees,
        AppConstants.collectionClients,
        AppConstants.collectionUsers, // fallback
      ];
      
      for (final collection in collections) {
        try {
          final doc = await firestore
              .collection(collection)
              .doc(userId)
              .get();
          
          if (doc.exists) {
            // Found the user, update in this collection
            await firestore
                .collection(collection)
                .doc(userId)
                .update({
              'isOnline': isOnline,
              'lastLoginAt': FieldValue.serverTimestamp(),
            });
            return;
          }
        } catch (e) {
          // Continue to next collection if this one fails
          print('Error searching collection $collection: $e');
        }
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  // Get user's assigned projects (searches across all role collections)
  static Stream<List<String>> getUserProjects(String userId) {
    // Search in all role collections to find the user
    final collections = [
      AppConstants.collectionManagers,
      AppConstants.collectionEmployees,
      AppConstants.collectionClients,
      AppConstants.collectionUsers, // fallback
    ];
    
    // Create a stream that searches all collections
    return Stream.fromFuture(() async {
      for (final collection in collections) {
        try {
          final doc = await firestore
              .collection(collection)
              .doc(userId)
              .get();
          
          if (doc.exists) {
            final user = UserModel.fromFirestore(doc);
            if (user.isManager) {
              return user.managedProjects;
            } else if (user.isEmployee) {
              return user.assignedProjects;
            } else if (user.isClient) {
              return user.clientProjects;
            }
          }
        } catch (e) {
          // Continue to next collection if this one fails
          print('Error searching collection $collection: $e');
        }
      }
      return <String>[];
    }());
  }

  // Batch operations
  static Future<void> batchUpdate(List<Map<String, dynamic>> operations) async {
    try {
      final batch = firestore.batch();
      
      for (final operation in operations) {
        final docRef = firestore
            .collection(operation['collection'])
            .doc(operation['documentId']);
        
        if (operation['type'] == 'set') {
          batch.set(docRef, operation['data']);
        } else if (operation['type'] == 'update') {
          batch.update(docRef, operation['data']);
        } else if (operation['type'] == 'delete') {
          batch.delete(docRef);
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Error in batch operation: $e');
      rethrow;
    }
  }
}

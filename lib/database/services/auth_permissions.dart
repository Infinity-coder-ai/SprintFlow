import '../models/user_model.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

/// Role checks and manager-side user administration.
class AuthPermissions {
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
      return false;
    }
  }

  // Validate user role for specific action
  static Future<bool> validateRole(
    String userId,
    List<String> allowedRoles,
  ) async {
    try {
      final userData = await FirebaseService.getUserData(userId);
      if (userData == null) return false;

      return allowedRoles.contains(userData.role);
    } catch (e) {
      return false;
    }
  }

  // Check if user can manage another user
  static Future<bool> canManageUser(
    String managerId,
    String targetUserId,
  ) async {
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
      return false;
    }
  }

  // Delete a managed user document.
  // Firebase Auth user deletion should be handled by a trusted backend/admin
  // flow, not directly from the client app.
  static Future<void> deleteUserAccount(
    String userId,
    String managerId,
  ) async {
    try {
      final canDelete = await canManageUser(managerId, userId);
      if (!canDelete) {
        throw AuthException('You do not have permission to delete this user');
      }

      await FirebaseService.deleteUserDocument(userId);
    } catch (e) {
      rethrow;
    }
  }
}

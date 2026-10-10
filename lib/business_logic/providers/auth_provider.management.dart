part of 'auth_provider.dart';

/// Password, profile, permission, and admin actions. Same library as
/// [AuthProvider], so every existing call site keeps working unchanged.
extension AuthProviderManagement on AuthProvider {
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
      return await AuthPermissions.hasPermission(_userData!.id, permission);
    } catch (e) {
      return false;
    }
  }

  // Validate role
  Future<bool> validateRole(List<String> allowedRoles) async {
    if (_userData == null) return false;

    try {
      return await AuthPermissions.validateRole(_userData!.id, allowedRoles);
    } catch (e) {
      return false;
    }
  }

  // Check if can manage user
  Future<bool> canManageUser(String targetUserId) async {
    if (_userData == null) return false;

    try {
      return await AuthPermissions.canManageUser(
        _userData!.id,
        targetUserId,
      );
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

      await AuthPermissions.deleteUserAccount(targetUserId, _userData!.id);
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
}

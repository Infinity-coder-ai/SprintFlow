part of 'auth_provider.dart';

/// Email-verification gating. Same library as [AuthProvider], so every
/// existing call site keeps working without new imports.
extension AuthProviderVerification on AuthProvider {
  /// Refreshes the verified flag from Firebase Auth. Call after the user
  /// returns from their inbox.
  Future<void> refreshEmailVerified() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      _emailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    } catch (_) {
      _emailVerified = false;
    }
    notifyListeners();
  }

  /// Returns the usable user record for [userId].
  ///
  /// Migrates a verified pending signup into `users` on first sight, so no
  /// database record ever exists before the email is verified. Returns null
  /// when there is neither a record nor a pending signup; sets the pending
  /// flag when an unverified signup is waiting.
  Future<UserModel?> resolveUserRecord(String userId) async {
    final existing = await FirebaseService.getUserData(userId);
    if (existing != null) return existing;

    final pending = await PendingRegistrationService.getPending(userId);
    if (pending == null) return null;

    await refreshEmailVerified();
    if (!_emailVerified) {
      _pendingEmail = pending['email'] as String? ?? '';
      return null;
    }
    final migrated = await PendingRegistrationService.migrateToUsers(userId);
    if (migrated == null) return null;
    _pendingEmail = null;
    return migrated;
  }

  /// Re-sends the verification link to the signed-in user.
  Future<bool> resendVerificationEmail() async {
    try {
      _setLoading(true);
      _clearError();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('No signed-in user found. Please sign in again.');
        return false;
      }
      await user.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('Failed to resend email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

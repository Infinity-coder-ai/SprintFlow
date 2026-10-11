part of 'auth_provider.dart';

/// Password-reset delivery. Same library as [AuthProvider], so the existing
/// call site keeps working without new imports.
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
}

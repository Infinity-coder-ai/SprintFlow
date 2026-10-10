part of 'auth_provider.dart';

/// Account-creation actions. Same library as [AuthProvider], so every
/// existing call site keeps working without new imports.
extension AuthProviderRegistration on AuthProvider {
  // Create manager account
  Future<bool> createManagerAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final cred = await AuthRegistration.createManagerAccount(
        email,
        password,
        name,
      );
      if (cred.user != null) {
        await _loadUserData(cred.user!.uid);
      }
      return true;
    } on AuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (await _recoverExistingAccount(email, password)) return true;
      }
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
    String name, {
    String? department,
    String? position,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_userData == null || !_userData!.isManager) {
        _setError('Only managers can create employee accounts');
        return false;
      }

      await AuthRegistration.createEmployeeAccount(
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

      final cred = await AuthRegistration.createEmployeeAccountSelf(
        email,
        password,
        name,
      );
      if (cred.user != null) {
        await _loadUserData(cred.user!.uid);
      }
      return true;
    } on AuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (await _recoverExistingAccount(email, password)) return true;
      }
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
    String name, {
    String? companyName,
    String? contactPerson,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_userData == null || !_userData!.isManager) {
        _setError('Only managers can create client accounts');
        return false;
      }

      await AuthRegistration.createClientAccount(
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
    String name, {
    String? companyName,
    String? contactPerson,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      final cred = await AuthRegistration.createClientAccountSelf(
        email,
        password,
        name,
        companyName: companyName,
        contactPerson: contactPerson,
      );
      if (cred.user != null) {
        await _loadUserData(cred.user!.uid);
      }
      return true;
    } on AuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (await _recoverExistingAccount(email, password)) return true;
      }
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Client registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Silent recovery for self-signup retries on an existing address.
  /// If the typed password matches, signs in so the flow routes correctly
  /// (Verify screen when still unverified, dashboard otherwise). Returns
  /// false without surfacing anything new, so callers keep their original
  /// duplicate message (e.g. wrong password). Never used for
  /// manager-created accounts.
  Future<bool> _recoverExistingAccount(String email, String password) async {
    try {
      final cred = await AuthService.signInWithEmailAndPassword(
        email.trim().toLowerCase(),
        password,
      );
      if (cred.user == null) return false;
      await _loadUserData(cred.user!.uid);
      return true;
    } catch (_) {
      return false;
    }
  }
}

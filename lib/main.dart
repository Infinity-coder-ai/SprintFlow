import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'business_logic/providers/auth_provider.dart';
import 'database/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'ui/auth/login_screen.dart';
import 'ui/manager/manager_workspace.dart';
import 'ui/employee/employee_workspace.dart';
import 'ui/client/client_workspace.dart';
import 'ui/auth/auth_theme.dart';
import 'ui/auth/verify_email_screen.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const SprintFlowApp());
}

class SprintFlowApp extends StatelessWidget {
  const SprintFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'SprintFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final auth = context.watch<AuthProvider>();
          if (auth.isManager && child != null) {
            return ManagerTheme(child: child);
          }
          if (auth.isEmployee && child != null) {
            return EmployeeTheme(child: child);
          }
          if (auth.isClient && child != null) {
            return ClientTheme(child: child);
          }
          if (!auth.isManager &&
              !auth.isEmployee &&
              !auth.isClient &&
              child != null) {
            return AuthTheme(child: child);
          }
          return child ?? const SizedBox.shrink();
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        if (authProvider.userData == null) {
          if (authProvider.hasPendingRegistration) {
            // Signed up but email not verified yet: no database record
            // exists, so the user waits here until verification completes.
            return VerifyEmailScreen(
              email: authProvider.pendingEmail ?? '',
            );
          }
          // Authenticated but no user document resolved yet.
          return const _AccountMissingScreen();
        }
        if (!authProvider.isEmailVerified) {
          // Signed in but the email address is not verified yet.
          // No unverified (possibly mistyped) address can reach a dashboard.
          return VerifyEmailScreen(email: authProvider.userData!.email);
        }
        if (authProvider.isManager) {
          return const ManagerWorkspace();
        } else if (authProvider.isEmployee) {
          return const EmployeeWorkspace();
        } else if (authProvider.isClient) {
          return const ClientWorkspace();
        }
        return const LoginScreen();
      },
    );
  }
}

class _AccountMissingScreen extends StatelessWidget {
  const _AccountMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SprintFlow')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined, size: 64),
              const SizedBox(height: 16),
              const Text('Account not fully set up'),
              const SizedBox(height: 8),
              Text(
                'We could not find your profile. Please sign out and sign in again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder:
                    (context, authProvider, child) => OutlinedButton.icon(
                      onPressed:
                          authProvider.isLoading ? null : authProvider.signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

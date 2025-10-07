import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_employee_screen.dart';
import 'screens/dashboard/manager_dashboard.dart';
import 'screens/dashboard/employee_dashboard.dart';
import 'screens/dashboard/client_dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/projects/project_form_screen.dart';
import 'screens/tasks/task_form_screen.dart';
import 'screens/tasks/work_update_screen.dart';

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
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register-employee': (context) => const RegisterEmployeeScreen(),
          '/manager-dashboard': (context) => const ManagerDashboard(),
          '/employee-dashboard': (context) => const EmployeeDashboard(),
          '/client-dashboard': (context) => const ClientDashboard(),
          '/projects': (context) => const ProjectFormScreen(),
          '/tasks': (context) => const TaskFormScreen(),
        },
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
          // If profile hasn't resolved, send to Login so the user can retry or see errors
          return const LoginScreen();
        }
        if (authProvider.isManager) {
          return const ManagerDashboard();
        } else if (authProvider.isEmployee) {
          return const EmployeeDashboard();
        } else if (authProvider.isClient) {
          return const ClientDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';

/// Dark palette shared by every employee screen.
class EmployeeColors {
  static const ink = Color(0xFF061225);
  static const panel = Color(0xFF0D1B31);
  static const panel2 = Color(0xFF122442);
  static const purple = Color(0xFF6937FF);
  static const purpleLight = Color(0xFF9A6BFF);
  static const white = Color(0xFFF7F8FF);
  static const muted = Color(0xFFAAB6CC);
  static const green = Color(0xFF28D58B);
  static const orange = Color(0xFFFFB020);
  static const red = Color(0xFFFF4F6D);
}

class EmployeeTheme extends StatelessWidget {
  final Widget child;

  const EmployeeTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: EmployeeColors.ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: EmployeeColors.purple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: EmployeeColors.ink,
          foregroundColor: EmployeeColors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: EmployeeColors.panel,
          labelStyle: TextStyle(color: EmployeeColors.muted),
          hintStyle: TextStyle(color: EmployeeColors.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: EmployeeColors.purpleLight),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Dark palette shared by every auth screen (login, sign up, forgot
/// password, splash). Same values as the manager/employee/client workspaces.
class AuthColors {
  static const Color ink = Color(0xFF061225);
  static const Color panel = Color(0xFF0D1B31);
  static const Color panel2 = Color(0xFF122442);
  static const Color purple = Color(0xFF6937FF);
  static const Color purpleLight = Color(0xFF9A6BFF);
  static const Color white = Color(0xFFF7F8FF);
  static const Color muted = Color(0xFFAAB6CC);
  static const Color green = Color(0xFF28D58B);
  static const Color orange = Color(0xFFFFB020);
  static const Color red = Color(0xFFFF4F6D);

  static const LinearGradient logoGradient = LinearGradient(
    colors: [Color(0xFF6937FF), Color(0xFF9A6BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AuthTheme extends StatelessWidget {
  final Widget child;

  const AuthTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AuthColors.ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AuthColors.purple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AuthColors.ink,
          foregroundColor: AuthColors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuthColors.purple,
            foregroundColor: AuthColors.white,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AuthColors.purpleLight,
            side: const BorderSide(color: AuthColors.purpleLight, width: 1.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AuthColors.purpleLight),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AuthColors.purple;
            return null;
          }),
        ),
        dividerTheme: const DividerThemeData(color: Colors.white24),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AuthColors.panel,
          labelStyle: TextStyle(color: AuthColors.muted),
          hintStyle: TextStyle(color: AuthColors.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AuthColors.purpleLight, width: 2),
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

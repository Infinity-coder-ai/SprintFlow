import 'package:flutter/material.dart';

/// Dark palette shared by every client screen.
class ClientColors {
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

class ClientTheme extends StatelessWidget {
  final Widget child;

  const ClientTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: ClientColors.ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ClientColors.purple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: ClientColors.ink,
          foregroundColor: ClientColors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: ClientColors.panel,
          labelStyle: TextStyle(color: ClientColors.muted),
          hintStyle: TextStyle(color: ClientColors.muted),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ClientColors.purpleLight),
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

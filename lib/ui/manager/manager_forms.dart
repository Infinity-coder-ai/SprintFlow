import 'package:flutter/material.dart';

import 'manager_theme.dart';

/// Form controls shared by manager input screens.
Widget primaryButton(String label, VoidCallback? onPressed) => SizedBox(
  height: 50,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: ManagerColors.purple,
      foregroundColor: ManagerColors.white,
    ),
    child: Text(label),
  ),
);

Widget field(
  TextEditingController controller,
  String label,
  String hint, {
  int lines = 1,
}) => TextField(
  controller: controller,
  maxLines: lines,
  style: const TextStyle(color: ManagerColors.white),
  decoration: InputDecoration(labelText: label, hintText: hint),
);

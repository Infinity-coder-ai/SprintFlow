import 'package:flutter/material.dart';

import 'employee_theme.dart';

/// Shared presentation widgets for every employee screen.
Widget topBar(BuildContext context, String title, IconData icon) {
  final canPop = Navigator.of(context).canPop();
  return Row(
    children: [
      if (canPop)
        const BackButton(color: EmployeeColors.white)
      else
        Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: EmployeeColors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      Icon(icon, color: EmployeeColors.purpleLight),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: EmployeeColors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}

Widget sectionTitle(
  BuildContext context,
  String title, {
  String? action,
  VoidCallback? onAction,
}) => Row(
  children: [
    Expanded(
      child: Text(
        title,
        style: const TextStyle(
          color: EmployeeColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    if (action != null)
      TextButton(
        onPressed: onAction,
        child: Text(
          action,
          style: const TextStyle(color: EmployeeColors.purpleLight),
        ),
      ),
  ],
);

Widget metric(String label, String value, IconData icon, Color color) =>
    darkCard(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Text(
              value,
              style: const TextStyle(
                color: EmployeeColors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: EmployeeColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

Widget detailStat(String label, String value) => darkCard(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: EmployeeColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: EmployeeColors.muted, fontSize: 11),
        ),
      ],
    ),
  ),
);

Widget darkCard({required Widget child}) =>
    TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: .97, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (context, value, card) {
        return Opacity(
          opacity: ((value - .97) / .03).clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(scale: value, child: card),
        );
      },
      child: Card(
        color: EmployeeColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.white10),
        ),
        child: child,
      ),
    );

Widget pill(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  decoration: BoxDecoration(
    color: color.withValues(alpha:.16),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: color == EmployeeColors.panel2 ? EmployeeColors.white : color,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  ),
);

Widget primaryButton(String label, VoidCallback? onPressed) => SizedBox(
  height: 50,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: EmployeeColors.purple,
      foregroundColor: EmployeeColors.white,
    ),
    child: Text(label),
  ),
);

Widget field(
  TextEditingController controller,
  String label,
  String hint, {
  int lines = 1,
  TextInputType? keyboard,
}) => TextField(
  controller: controller,
  maxLines: lines,
  keyboardType: keyboard,
  style: const TextStyle(color: EmployeeColors.white),
  decoration: InputDecoration(labelText: label, hintText: hint),
);

Widget errorCard(String message) => darkCard(
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: EmployeeColors.red),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: EmployeeColors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  ),
);

Widget emptyView(String message) => Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: EmployeeColors.muted),
    ),
  ),
);

String initialOf(String value) =>
    value.trim().isEmpty ? '?' : value.trim().substring(0, 1).toUpperCase();

String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

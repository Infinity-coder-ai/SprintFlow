import 'package:flutter/material.dart';

import 'manager_theme.dart';

/// Shared presentation widgets for every manager screen.
/// Shows a menu button on tab pages and a back button on pushed pages.
Widget topBar(
  BuildContext context,
  String title,
  IconData icon, {
  IconData? action,
  VoidCallback? onAction,
}) {
  final canPop = Navigator.of(context).canPop();
  return Row(
    children: [
      if (canPop)
        const BackButton(color: ManagerColors.white)
      else
        Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: ManagerColors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      Icon(icon, color: ManagerColors.purpleLight),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: ManagerColors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      if (action != null)
        IconButton(
          onPressed: onAction,
          icon: Icon(action, color: ManagerColors.white),
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
          color: ManagerColors.white,
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
          style: const TextStyle(color: ManagerColors.purpleLight),
        ),
      ),
  ],
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
        color: ManagerColors.panel,
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
    color: color.withOpacity(.16),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: color == ManagerColors.panel2 ? ManagerColors.white : color,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  ),
);

Widget errorCard(String message) => darkCard(
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: ManagerColors.red),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: ManagerColors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  ),
);

Widget legendRow(String label, int count, Color color) => Row(
  children: [
    Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        label,
        style: const TextStyle(color: ManagerColors.muted, fontSize: 13),
      ),
    ),
    Text(
      '$count',
      style: const TextStyle(
        color: ManagerColors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
  ],
);

Widget emptyView(String message) => Center(
  child: Padding(
    padding: const EdgeInsets.all(32),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: ManagerColors.muted),
    ),
  ),
);

String initialOf(String value) =>
    value.trim().isEmpty ? '?' : value.trim().substring(0, 1).toUpperCase();

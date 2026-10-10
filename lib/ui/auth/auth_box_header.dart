import 'package:flutter/material.dart';

import 'auth_theme.dart';

/// Rounded-box brand header shared by the register screens.
class AuthBoxHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthBoxHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AuthColors.purple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AuthColors.purple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: AuthColors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: AuthColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

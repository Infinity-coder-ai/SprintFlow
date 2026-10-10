import 'package:flutter/material.dart';

import 'auth_theme.dart';

/// Branded header shared by login and forgot-password screens:
/// rocket logo in a purple gradient circle, title, and subtitle.
class AuthHeader extends StatelessWidget {
  final IconData icon;
  final double size;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AuthColors.logoGradient,
            boxShadow: [
              BoxShadow(
                color: AuthColors.purple.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: AuthColors.white, size: size * 0.5),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AuthColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AuthColors.muted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

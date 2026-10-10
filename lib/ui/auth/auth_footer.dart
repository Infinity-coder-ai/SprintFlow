import 'package:flutter/material.dart';

import 'auth_theme.dart';

/// Small explanatory note plus app version, shared by auth screens.
class AuthFooter extends StatelessWidget {
  final String note;
  const AuthFooter({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          note,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AuthColors.muted),
        ),
        const SizedBox(height: 16),
        Text(
          'Version 1.0.0',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AuthColors.muted),
        ),
      ],
    );
  }
}

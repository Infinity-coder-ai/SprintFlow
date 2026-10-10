import 'package:flutter/material.dart';

import 'widgets/custom_button.dart';
import 'auth_footer.dart';
import 'auth_theme.dart';
import 'register_client_screen.dart';
import 'register_employee_screen.dart';
import 'register_screen.dart';

/// Sign-in button, account-type shortcuts, and footer for the login screen.
Widget loginActions({
  required BuildContext context,
  required bool isLoading,
  required VoidCallback onSignIn,
}) {
  return Column(
    children: [
      CustomButton(
        onPressed: isLoading ? null : onSignIn,
        text: isLoading ? 'Signing In...' : 'Sign In',
        isLoading: isLoading,
      ),
      const SizedBox(height: 16),
      const Row(
        children: [
          Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('OR', style: TextStyle(color: AuthColors.muted)),
          ),
          Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
      const SizedBox(height: 16),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Create an account',
          style: TextStyle(
            color: AuthColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text('Manager account'),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterEmployeeScreen(),
                ),
              ),
          icon: const Icon(Icons.person_outline),
          label: const Text('Employee account'),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterClientScreen()),
              ),
          icon: const Icon(Icons.business_outlined),
          label: const Text('Client account'),
        ),
      ),
      const SizedBox(height: 32),
      const AuthFooter(
        note:
            'Managers can create team accounts, employees can self-register, and clients can join with their own account.',
      ),
    ],
  );
}

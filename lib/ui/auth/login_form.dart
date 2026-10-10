import 'package:flutter/material.dart';

import 'widgets/custom_text_field.dart';
import 'widgets/glass_card.dart';
import 'auth_theme.dart';

/// Sign-in form card: email, password, remember-me and forgot-password row.
/// State stays in the login screen; this is pure presentation.
Widget loginForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required bool isPasswordVisible,
  required VoidCallback onToggleVisibility,
  required bool rememberMe,
  required ValueChanged<bool> onRememberChanged,
  required VoidCallback onForgotPassword,
}) {
  return GlassCard(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: !isPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AuthColors.muted,
                ),
                onPressed: onToggleVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: AuthColors.purple,
                      onChanged: (value) => onRememberChanged(value ?? false),
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: AuthColors.white),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AuthColors.purpleLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

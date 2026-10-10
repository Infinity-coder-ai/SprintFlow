import 'package:flutter/material.dart';

import 'widgets/custom_text_field.dart';
import 'widgets/glass_card.dart';
import 'auth_theme.dart';

/// Manager registration fields plus terms row.
/// Controllers and submit logic stay in the screen; this is presentation.
Widget registerForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController nameController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController confirmPasswordController,
  required bool isPasswordVisible,
  required VoidCallback onTogglePassword,
  required bool isConfirmVisible,
  required VoidCallback onToggleConfirm,
  required bool agreeToTerms,
  required ValueChanged<bool> onAgreeChanged,
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
              controller: nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter your email address',
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
                onPressed: onTogglePassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              obscureText: !isConfirmVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                  color: AuthColors.muted,
                ),
                onPressed: onToggleConfirm,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  activeColor: AuthColors.purple,
                  onChanged: (value) => onAgreeChanged(value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: TextStyle(color: AuthColors.white),
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

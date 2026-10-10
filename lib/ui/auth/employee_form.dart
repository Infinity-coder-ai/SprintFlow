import 'package:flutter/material.dart';

import 'widgets/custom_text_field.dart';
import 'widgets/glass_card.dart';
import 'auth_theme.dart';

/// Employee registration fields plus terms row.
/// Controllers and submit logic stay in the screen; this is presentation.
Widget employeeForm({
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
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: nameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              labelText: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: !isPasswordVisible,
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
            const SizedBox(height: 20),
            CustomTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: !isConfirmVisible,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  activeColor: AuthColors.purple,
                  onChanged: (value) => onAgreeChanged(value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms and Conditions',
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

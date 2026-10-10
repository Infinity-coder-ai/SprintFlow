import 'package:flutter/material.dart';

import 'widgets/custom_text_field.dart';
import 'widgets/glass_card.dart';
import 'auth_theme.dart';

/// Client registration fields plus terms row.
/// Controllers and submit logic stay in the screen; this is presentation.
Widget clientForm({
  required GlobalKey<FormState> formKey,
  required TextEditingController nameController,
  required TextEditingController emailController,
  required TextEditingController passwordController,
  required TextEditingController companyController,
  required TextEditingController contactController,
  required bool isPasswordVisible,
  required VoidCallback onToggleVisibility,
  required bool agree,
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
              hintText: 'Enter your name',
              prefixIcon: Icons.person_outline,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'client@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$',
                ).hasMatch(v)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              hintText: 'Minimum 6 characters',
              prefixIcon: Icons.lock_outline,
              obscureText: !isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AuthColors.muted,
                ),
                onPressed: onToggleVisibility,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter a password';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: companyController,
              labelText: 'Company (optional)',
              hintText: 'Acme Inc.',
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: contactController,
              labelText: 'Contact Person (optional)',
              hintText: 'John Doe',
              prefixIcon: Icons.contacts_outlined,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: agree,
                  activeColor: AuthColors.purple,
                  onChanged: (v) => onAgreeChanged(v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I agree to the Terms and Privacy Policy.',
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

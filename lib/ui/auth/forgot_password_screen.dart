import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/glass_card.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';
import 'auth_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reset link sent! Check your inbox and spam folder. '
            'It only arrives if this email is registered.',
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to send reset email'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.ink,
      appBar: AppBar(title: const Text('Forgot Password'), elevation: 0),
      body: Container(
        color: AuthColors.ink,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Reset Form
                  _buildResetForm(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AuthColors.purpleLight.withOpacity(0.1),
            border: Border.all(color: AuthColors.purpleLight, width: 2),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 40,
            color: AuthColors.purpleLight,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AuthColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AuthColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _emailController,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            CustomButton(
              onPressed: authProvider.isLoading ? null : _handleResetPassword,
              text: authProvider.isLoading ? 'Sending...' : 'Send Reset Link',
              isLoading: authProvider.isLoading,
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back to Sign In',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AuthColors.purpleLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

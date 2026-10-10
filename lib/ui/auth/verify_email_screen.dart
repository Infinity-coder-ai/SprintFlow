import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/auth_provider.dart';
import 'auth_header.dart';
import 'auth_theme.dart';
import 'widgets/custom_button.dart';

/// Shown instead of any dashboard while the signed-in user's email is
/// still unverified. No stale or mistyped address can get past this screen.
class VerifyEmailScreen extends StatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Verification link sent to ${widget.email}. Check your inbox and spam folder.'
                : (authProvider.error ?? 'Failed to resend email'),
          ),
          backgroundColor: ok ? AuthColors.green : AuthColors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshEmailVerified();
      if (!mounted) return;
      if (!authProvider.isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Still not verified. Click the link in the email, then try again.',
            ),
            backgroundColor: AuthColors.red,
          ),
        );
        return;
      }
      // Verified: migrate the pending profile into the database, then
      // AuthWrapper automatically routes to the dashboard.
      await authProvider.refreshUserData();
      if (!mounted) return;
      if (authProvider.userData == null &&
          !authProvider.hasPendingRegistration) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verified, but no profile was found. Please sign up again.',
            ),
            backgroundColor: AuthColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.ink,
      appBar: AppBar(title: const Text('Verify Email'), elevation: 0),
      body: Container(
        color: AuthColors.ink,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                AuthHeader(
                  icon: Icons.mark_email_read_outlined,
                  title: 'Verify your email',
                  subtitle:
                      'We sent a verification link to ${widget.email}. '
                      'You need to verify before signing in.',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: _sending ? null : _resend,
                  text: _sending ? 'Sending...' : 'Resend Link',
                  isLoading: _sending,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  onPressed: _checking ? null : _checkVerified,
                  text: _checking ? 'Checking...' : 'I Verified — Continue',
                  isLoading: _checking,
                  isOutlined: true,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      () => Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut(),
                  child: const Text(
                    'Use a different account',
                    style: TextStyle(
                      color: AuthColors.purpleLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

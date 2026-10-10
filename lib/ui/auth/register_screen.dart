import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/custom_button.dart';
import 'auth_theme.dart';
import 'register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.createManagerAccount(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.ink,
      appBar: AppBar(
        title: const Text('Create Manager Account'),
        elevation: 0,
      ),
      body: Container(
        color: AuthColors.ink,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 64,
                  color: AuthColors.purpleLight,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create Manager Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AuthColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only managers can create accounts. Employees and clients must be invited.',
                  style: TextStyle(color: AuthColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                registerForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                  isConfirmVisible: _isConfirmPasswordVisible,
                  onToggleConfirm:
                      () => setState(
                        () =>
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                      ),
                  agreeToTerms: _agreeToTerms,
                  onAgreeChanged: (value) => setState(() {
                    _agreeToTerms = value;
                  }),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        CustomButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleRegister,
                          text:
                              authProvider.isLoading
                                  ? 'Creating Account...'
                                  : 'Create Account',
                          isLoading: authProvider.isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Already have an account? Sign In',
                            style: TextStyle(
                              color: AuthColors.purpleLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

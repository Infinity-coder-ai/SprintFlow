import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/custom_button.dart';
import 'auth_box_header.dart';
import 'auth_theme.dart';
import 'client_form.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactController = TextEditingController();
  bool _agree = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and privacy policy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.createClientAccountSelf(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      companyName:
          _companyController.text.trim().isEmpty
              ? null
              : _companyController.text.trim(),
      contactPerson:
          _contactController.text.trim().isEmpty
              ? null
              : _contactController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client account created successfully. You can now sign in.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.ink,
      body: Container(
        color: AuthColors.ink,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const AuthBoxHeader(
                  icon: Icons.business_outlined,
                  title: 'Create Client Account',
                  subtitle:
                      'Join SprintFlow as a client and track project progress',
                ),
                const SizedBox(height: 28),
                clientForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  companyController: _companyController,
                  contactController: _contactController,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                  agree: _agree,
                  onAgreeChanged: (v) => setState(() => _agree = v),
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      text:
                          authProvider.isLoading
                              ? 'Creating Account...'
                              : 'Create Client Account',
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      color: AuthColors.purpleLight,
                      fontWeight: FontWeight.w600,
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

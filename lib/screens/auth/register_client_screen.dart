import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/custom_text_field.dart';

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
    if (!_formKey.currentState!.validate() || !_agree) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.createClientAccountSelf(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      companyName: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
      contactPerson: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Client account created'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Client Account'), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'client@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter email';
                      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$').hasMatch(v)) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _companyController,
                    labelText: 'Company (optional)',
                    hintText: 'Acme Inc.',
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _contactController,
                    labelText: 'Contact Person (optional)',
                    hintText: 'John Doe',
                    prefixIcon: Icons.contacts_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
                      const Expanded(child: Text('I agree to the Terms and Privacy Policy.')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

class InviteEmployeeScreen extends StatefulWidget {
  const InviteEmployeeScreen({super.key});

  @override
  State<InviteEmployeeScreen> createState() => _InviteEmployeeScreenState();
}

class _InviteEmployeeScreenState extends State<InviteEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController(text: 'Temp@123');
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (!_formKey.currentState!.validate()) return;
    final manager = Provider.of<AuthProvider>(context, listen: false).userData;
    if (manager == null) return;
    setState(() => _loading = true);
    try {
      await AuthService.createEmployeeAccountSecondary(
        _email.text.trim(),
        _password.text.trim(),
        _name.text.trim(),
        manager.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee invited'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _name,
                labelText: 'Full name',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _email,
                labelText: 'Email',
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _password,
                labelText: 'Temp Password',
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              CustomButton(onPressed: _loading ? null : _invite, text: _loading ? 'Inviting...' : 'Invite Employee', isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}



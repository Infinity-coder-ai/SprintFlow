import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/project_service.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientController = TextEditingController(); // accepts email or UID
  DateTime? _expectedFinish;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _expectedFinish = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final managerId = auth.userData?.id;
    if (managerId == null) return;

    setState(() => _saving = true);
    try {
      // Do NOT require the client to pre-exist. Accept email or UID and store as provided.
      final String clientInput = _clientController.text.trim();
      final String? clientId = clientInput.contains('@') ? null : (clientInput.isEmpty ? null : clientInput);
      final String? clientEmail = clientInput.contains('@') ? clientInput : null;

      await ProjectService().createProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        managerId: managerId,
        clientId: clientId,
        clientEmail: clientEmail,
        expectedFinish: _expectedFinish,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created'), backgroundColor: AppColors.success),
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Title',
                hintText: 'Project title',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Short description',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _clientController,
                labelText: 'Client (email or UID)',
                hintText: 'e.g. client@example.com or client UID',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.business,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _expectedFinish != null ? 'Due: ${_expectedFinish!.toLocal().toString().split(' ').first}' : 'No deadline selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _saving ? null : _submit,
                text: _saving ? 'Saving...' : 'Create Project',
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

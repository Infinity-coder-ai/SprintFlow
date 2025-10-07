import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/task_service.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class TaskFormScreen extends StatefulWidget {
  final String? projectId; // preselected project
  final UserModel? assignedEmployee; // preselected employee
  const TaskFormScreen({super.key, this.projectId, this.assignedEmployee});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController(); // employee email
  String? _projectId;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_projectId == null) {
      _projectId = widget.projectId ?? (ModalRoute.of(context)?.settings.arguments as String?);
    }
    
    // Pre-fill employee email if assigned
    if (widget.assignedEmployee != null && _assigneeController.text.isEmpty) {
      _assigneeController.text = widget.assignedEmployee!.email;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final managerId = auth.userData?.id;
    if (managerId == null) return;
    if (_projectId == null || _projectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing project context')),);
      return;
    }

    setState(() => _saving = true);
    try {
      // Find employee by email - they must create their own account first
      final email = _assigneeController.text.trim();
      final emp = await FirebaseService.getUserByEmail(email);
      if (emp == null) {
        throw Exception('Employee with email $email not found. Please ask the employee to create an account first using the "Create Employee Account" option on the login screen.');
      }
      if (emp.role != AppConstants.roleEmployee) {
        throw Exception('User with email $email is not an employee.');
      }
      final assignedUserId = emp.id;

      await TaskService().createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectId: _projectId!,
        createdBy: managerId,
        assignedTo: assignedUserId,
        priority: AppConstants.priorityMedium,
        deadline: _deadline,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created'), backgroundColor: AppColors.success),
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
      appBar: AppBar(title: const Text('Create Task')),
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
                hintText: 'Task title',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Task details',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _assigneeController,
                labelText: 'Employee Email',
                hintText: 'employee@company.com',
                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 8),
              Text(
                'Note: Employee must create an account first using the "Create Employee Account" option on the login screen.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline != null
                          ? 'Deadline: ${_deadline!.toLocal().toString().split(' ').first}'
                          : 'No deadline selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDeadline,
                    icon: const Icon(Icons.event),
                    label: const Text('Pick deadline'),
                  )
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _saving ? null : _submit,
                text: _saving ? 'Saving...' : 'Create Task',
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/work_update_service.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

class EmployeeUpdateProgressPage extends StatefulWidget {
  final TaskModel task;
  final UserModel employee;
  const EmployeeUpdateProgressPage({
    super.key,
    required this.task,
    required this.employee,
  });

  @override
  State<EmployeeUpdateProgressPage> createState() =>
      _EmployeeUpdateProgressPageState();
}

class _EmployeeUpdateProgressPageState
    extends State<EmployeeUpdateProgressPage> {
  final _message = TextEditingController();
  final _hours = TextEditingController();
  late double _progress;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.task.progressPercentage.clamp(0.0, 100.0);
  }

  @override
  void dispose() {
    _message.dispose();
    _hours.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final message = _message.text.trim();
    if (message.isEmpty) {
      _showMessage('Please describe what you worked on.', error: true);
      return;
    }
    final hours = int.tryParse(_hours.text.trim());
    if (hours == null || hours < 0) {
      _showMessage('Enter valid work hours (0 or more).', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await WorkUpdateService().createWorkUpdate(
        taskId: widget.task.id,
        employeeId: widget.employee.id,
        projectId: widget.task.projectId,
        update: message,
        workHours: hours,
        progressPercentage: _progress.round(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progress updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage('Failed to save update: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? EmployeeColors.red : EmployeeColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Progress')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            widget.task.title,
            style: const TextStyle(
              color: EmployeeColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          darkCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Progress',
                          style: TextStyle(
                            color: EmployeeColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_progress.round()}%',
                        style: const TextStyle(
                          color: EmployeeColors.purpleLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _progress,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: EmployeeColors.purpleLight,
                    label: '${_progress.round()}%',
                    onChanged: (value) => setState(() => _progress = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          field(_hours, 'Work Hours', 'e.g. 4', keyboard: TextInputType.number),
          const SizedBox(height: 14),
          field(
            _message,
            'Update Message',
            'Share what you worked on...',
            lines: 5,
          ),
          const SizedBox(height: 18),
          primaryButton(
            _saving ? 'Saving...' : 'Save Update',
            _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

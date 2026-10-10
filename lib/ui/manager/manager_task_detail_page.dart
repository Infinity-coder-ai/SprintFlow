import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/task_model.dart';
import '../../database/services/task_service.dart';
import 'manager_forms.dart';
import 'manager_labels.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerTaskDetailPage extends StatefulWidget {
  final TaskModel task;
  const ManagerTaskDetailPage({super.key, required this.task});

  @override
  State<ManagerTaskDetailPage> createState() => _ManagerTaskDetailPageState();
}

class _ManagerTaskDetailPageState extends State<ManagerTaskDetailPage> {
  bool working = false;

  Future<void> _changeStatus(String status) async {
    setState(() => working = true);
    try {
      if (status == AppConstants.statusDone) {
        await TaskService().completeTask(widget.task.id);
      } else {
        await TaskService().moveTaskStatus(widget.task.id, status);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task Details')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          widget.task.title,
          style: const TextStyle(
            color: ManagerColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        darkCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(color: ManagerColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.task.description,
                  style: const TextStyle(color: ManagerColors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Status: ${statusLabel(widget.task.status)}',
                  style: const TextStyle(color: ManagerColors.white),
                ),
                Text(
                  'Priority: ${priorityLabel(widget.task.priority)}',
                  style: const TextStyle(color: ManagerColors.white),
                ),
                Text(
                  'Progress: ${widget.task.progressPercentage.toInt()}%',
                  style: const TextStyle(color: ManagerColors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        primaryButton(
          working ? 'Updating...' : 'Mark In Progress',
          working ? null : () => _changeStatus(AppConstants.statusInProgress),
        ),
        const SizedBox(height: 10),
        primaryButton(
          working ? 'Updating...' : 'Mark Complete',
          working ? null : () => _changeStatus(AppConstants.statusDone),
        ),
      ],
    ),
  );
}

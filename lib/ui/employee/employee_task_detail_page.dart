import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/models/work_update_model.dart';
import '../../database/services/task_service.dart';
import '../../database/services/work_update_service.dart';
import 'employee_labels.dart';
import 'employee_theme.dart';
import 'employee_tiles.dart';
import 'employee_update_progress_page.dart';
import 'employee_widgets.dart';

class EmployeeTaskDetailPage extends StatefulWidget {
  final TaskModel task;
  final UserModel employee;
  const EmployeeTaskDetailPage({
    super.key,
    required this.task,
    required this.employee,
  });

  @override
  State<EmployeeTaskDetailPage> createState() => _EmployeeTaskDetailPageState();
}

class _EmployeeTaskDetailPageState extends State<EmployeeTaskDetailPage> {
  bool _working = false;

  Future<void> _markComplete() async {
    setState(() => _working = true);
    try {
      await TaskService().completeTask(widget.task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskModel?>(
      stream: TaskService().streamTasksForAssignee(widget.employee.id).map((
        tasks,
      ) {
        for (final task in tasks) {
          if (task.id == widget.task.id) return task;
        }
        return null;
      }),
      builder: (context, snapshot) {
        final task = snapshot.data ?? widget.task;
        final done = task.status == AppConstants.statusDone;
        return Scaffold(
          appBar: AppBar(title: const Text('Task Details')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        color: EmployeeColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  pill(
                    priorityLabel(task.priority),
                    priorityColor(task.priority),
                  ),
                ],
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
                        style: TextStyle(color: EmployeeColors.muted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description.isEmpty
                            ? 'No description.'
                            : task.description,
                        style: const TextStyle(color: EmployeeColors.white),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          pill(
                            statusLabel(task.status),
                            statusColor(task.status),
                          ),
                          if (task.deadline != null)
                            pill(
                              'Due ${formatDate(task.deadline!)}',
                              EmployeeColors.muted,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (task.progressPercentage / 100).clamp(0.0, 1.0),
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          EmployeeColors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${task.progressPercentage.toInt()}% complete',
                        style: const TextStyle(color: EmployeeColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              primaryButton(
                _working
                    ? 'Updating...'
                    : (done ? 'Completed' : 'Update Progress'),
                (done || _working)
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => EmployeeUpdateProgressPage(
                              task: task,
                              employee: widget.employee,
                            ),
                      ),
                    ),
              ),
              const SizedBox(height: 10),
              primaryButton(
                _working ? 'Updating...' : 'Mark Complete',
                (done || _working) ? null : _markComplete,
              ),
              const SizedBox(height: 20),
              const Text(
                'My Work Updates',
                style: TextStyle(
                  color: EmployeeColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<WorkUpdateModel>>(
                stream: WorkUpdateService().streamWorkUpdatesForTaskByEmployee(
                  task.id,
                  widget.employee.id,
                ),
                builder: (context, updateSnapshot) {
                  final updates =
                      updateSnapshot.data ?? const <WorkUpdateModel>[];
                  if (updates.isEmpty) {
                    return emptyView(
                      'No updates posted yet. Use Update Progress to log your work.',
                    );
                  }
                  return Column(
                    children: updates.map(workUpdateTile).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

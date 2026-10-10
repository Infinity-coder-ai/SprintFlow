import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'manager_assignee_field.dart';
import 'manager_forms.dart';
import 'manager_logic.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerCreateTaskPage extends StatefulWidget {
  final UserModel manager;
  const ManagerCreateTaskPage({super.key, required this.manager});
  @override
  State<ManagerCreateTaskPage> createState() => _ManagerCreateTaskPageState();
}

class _ManagerCreateTaskPageState extends State<ManagerCreateTaskPage> {
  final title = TextEditingController();
  final description = TextEditingController();
  String? projectId;
  String? employeeId;
  String priority = AppConstants.priorityMedium;
  bool saving = false;
  Future<List<UserModel>>? _teamFuture;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void _onProjectChanged(String? value) {
    setState(() {
      projectId = value;
      employeeId = null;
      _teamFuture = value == null ? null : loadProjectTeam(value);
    });
  }

  Future<void> _create() async {
    if (projectId == null ||
        title.text.trim().isEmpty ||
        description.text.trim().isEmpty) {
      _message(
        'Select a project and enter a title and description.',
        error: true,
      );
      return;
    }
    if (employeeId != null) {
      final team = await _teamFuture;
      final isMember = team?.any((user) => user.id == employeeId) ?? false;
      if (!isMember) {
        _message('That employee has not joined this project yet.', error: true);
        return;
      }
    }
    setState(() => saving = true);
    try {
      await TaskService().createTask(
        title: title.text.trim(),
        description: description.text.trim(),
        projectId: projectId!,
        createdBy: widget.manager.id,
        assignedTo: employeeId,
        priority: priority,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task created')));
        Navigator.pop(context);
      }
    } catch (e) {
      _message('Failed to create task: $e', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? ManagerColors.red : ManagerColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<ProjectModel>>(
        stream: ProjectService().streamProjectsForManager(widget.manager.id),
        builder: (context, snapshot) {
          final projects = snapshot.data ?? const <ProjectModel>[];
          final validProject =
              projects.any((p) => p.id == projectId) ? projectId : null;
          if (validProject != projectId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  projectId = validProject;
                  employeeId = null;
                  _teamFuture = null;
                });
              }
            });
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Create Task')),
            body: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (projects.isEmpty)
                  const InputDecorator(
                    decoration: InputDecoration(labelText: 'Project *'),
                    child: Text(
                      'No projects yet. Create a project first.',
                      style: TextStyle(
                        color: ManagerColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: validProject,
                    decoration: const InputDecoration(labelText: 'Project *'),
                    dropdownColor: ManagerColors.panel2,
                    style: const TextStyle(color: ManagerColors.white),
                    items:
                        projects
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(
                                  p.title,
                                  style: const TextStyle(
                                    color: ManagerColors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: _onProjectChanged,
                  ),
                const SizedBox(height: 14),
                field(title, 'Task Title', 'Enter task title'),
                const SizedBox(height: 14),
                field(
                  description,
                  'Description',
                  'Enter task description...',
                  lines: 4,
                ),
                const SizedBox(height: 14),
                if (projectId != null)
                  ManagerAssigneeField(
                    teamFuture: _teamFuture,
                    value: employeeId,
                    onChanged: (v) => setState(() => employeeId = v),
                  ),
                if (projectId != null) const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  dropdownColor: ManagerColors.panel2,
                  style: const TextStyle(color: ManagerColors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'low',
                      child: Text(
                        'Low',
                        style: TextStyle(color: ManagerColors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text(
                        'Medium',
                        style: TextStyle(color: ManagerColors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text(
                        'High',
                        style: TextStyle(color: ManagerColors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'critical',
                      child: Text(
                        'Critical',
                        style: TextStyle(color: ManagerColors.white),
                      ),
                    ),
                  ],
                  onChanged:
                      (value) => setState(() => priority = value ?? priority),
                ),
                const SizedBox(height: 14),
                primaryButton(
                  saving ? 'Creating...' : 'Create Task',
                  saving ? null : _create,
                ),
              ],
            ),
          );
        },
      );

}

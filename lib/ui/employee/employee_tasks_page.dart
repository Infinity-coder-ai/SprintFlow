import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'employee_logic.dart';
import 'employee_task_detail_page.dart';
import 'employee_theme.dart';
import 'employee_tiles.dart';
import 'employee_widgets.dart';

class EmployeeTasksPage extends StatefulWidget {
  final UserModel employee;
  const EmployeeTasksPage({super.key, required this.employee});

  @override
  State<EmployeeTasksPage> createState() => _EmployeeTasksPageState();
}

class _EmployeeTasksPageState extends State<EmployeeTasksPage> {
  final _search = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForEmployeeInclusive(
        widget.employee.id,
      ),
      builder: (context, projectSnapshot) {
        final projectNames = {
          for (final p in projectSnapshot.data ?? const <ProjectModel>[])
            p.id: p.title,
        };
        return StreamBuilder<List<TaskModel>>(
          stream: TaskService().streamTasksForAssignee(widget.employee.id),
          builder: (context, taskSnapshot) {
            final tasks = filterTasks(
              taskSnapshot.data ?? const <TaskModel>[],
              _search.text,
              _filter,
            );
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  topBar(context, 'My Tasks', Icons.check_box_outlined),
                  if (projectSnapshot.hasError)
                    errorCard(
                      'Couldn\'t load projects: ${projectSnapshot.error}',
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: EmployeeColors.white),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: EmployeeColors.muted,
                      ),
                      hintText: 'Search tasks...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['All', 'To Do', 'In Progress', 'Done'].map((label) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                labelStyle: TextStyle(
                                  color:
                                      _filter == label
                                          ? EmployeeColors.white
                                          : EmployeeColors.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                                selected: _filter == label,
                                selectedColor: EmployeeColors.purple.withValues(alpha:
                                  .35,
                                ),
                                onSelected:
                                    (_) => setState(() => _filter = label),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...tasks.map(
                    (task) => taskTile(
                      context,
                      task,
                      projectNames[task.projectId] ?? 'Project',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeTaskDetailPage(
                                    task: task,
                                    employee: widget.employee,
                                  ),
                            ),
                          ),
                    ),
                  ),
                  if (tasks.isEmpty) emptyView('No tasks found.'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

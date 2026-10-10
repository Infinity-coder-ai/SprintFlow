import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'employee_logic.dart';
import 'employee_project_details_page.dart';
import 'employee_theme.dart';
import 'employee_tiles.dart';
import 'employee_widgets.dart';

class EmployeeProjectsPage extends StatefulWidget {
  final UserModel employee;
  const EmployeeProjectsPage({super.key, required this.employee});

  @override
  State<EmployeeProjectsPage> createState() => _EmployeeProjectsPageState();
}

class _EmployeeProjectsPageState extends State<EmployeeProjectsPage> {
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
        final projects = filterProjects(
          projectSnapshot.data ?? const <ProjectModel>[],
          _search.text,
          _filter,
        );
        return StreamBuilder<List<TaskModel>>(
          stream: TaskService().streamTasksForAssignee(widget.employee.id),
          builder: (context, taskSnapshot) {
            final myTasks = taskSnapshot.data ?? const <TaskModel>[];
            final counts = <String, int>{};
            for (final task in myTasks) {
              counts[task.projectId] = (counts[task.projectId] ?? 0) + 1;
            }
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  topBar(context, 'My Projects', Icons.folder_outlined),
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
                      hintText: 'Search projects...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ['All', 'Active', 'Completed', 'On Hold']
                              .map(
                                (label) => Padding(
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
                                    selectedColor: EmployeeColors.purple
                                        .withValues(alpha:.35),
                                    onSelected:
                                        (_) =>
                                            setState(() => _filter = label),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...projects.map(
                    (project) => projectTile(
                      context,
                      project,
                      counts[project.id] ?? 0,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeProjectDetailsPage(
                                    project: project,
                                    employee: widget.employee,
                                  ),
                            ),
                          ),
                    ),
                  ),
                  if (projects.isEmpty)
                    emptyView(
                      'No projects yet. Accept an invitation to join one.',
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import 'manager_create_task_page.dart';
import 'manager_logic.dart';
import 'manager_task_detail_page.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerTasksPage extends StatefulWidget {
  final UserModel manager;
  const ManagerTasksPage({super.key, required this.manager});

  @override
  State<ManagerTasksPage> createState() => _ManagerTasksPageState();
}

class _ManagerTasksPageState extends State<ManagerTasksPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForManager(widget.manager.id),
      builder: (context, projectSnapshot) {
        final projects = projectSnapshot.data ?? const <ProjectModel>[];
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              topBar(
                context,
                'Tasks',
                Icons.check_box_outlined,
                action: Icons.add,
                onAction:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ManagerCreateTaskPage(
                              manager: widget.manager,
                            ),
                      ),
                    ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['All', 'To Do', 'In Progress', 'Review', 'Done'].map((
                        label,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            labelStyle: TextStyle(
                              color:
                                  _filter == label
                                      ? ManagerColors.white
                                      : ManagerColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                            selected: _filter == label,
                            selectedColor: ManagerColors.purple.withOpacity(
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
              FutureBuilder<List<TaskModel>>(
                future: loadTasksForProjects(projects),
                builder: (context, snapshot) {
                  final tasks = filterTasks(
                    snapshot.data ?? const <TaskModel>[],
                    _filter,
                  );
                  return Column(
                    children: [
                      ...tasks.map(
                        (task) => taskTile(
                          context,
                          task,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          ManagerTaskDetailPage(task: task),
                                ),
                              ),
                        ),
                      ),
                      if (tasks.isEmpty) emptyView('No tasks created yet.'),
                    ],
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

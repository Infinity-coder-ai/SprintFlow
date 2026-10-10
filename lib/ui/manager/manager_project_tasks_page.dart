import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/services/task_service.dart';
import 'manager_logic.dart';
import 'manager_task_detail_page.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerProjectTasksPage extends StatefulWidget {
  final ProjectModel project;
  const ManagerProjectTasksPage({super.key, required this.project});
  @override
  State<ManagerProjectTasksPage> createState() =>
      _ManagerProjectTasksPageState();
}

class _ManagerProjectTasksPageState extends State<ManagerProjectTasksPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService().streamTasksForProject(widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load tasks: ${snapshot.error}'),
            );
          }
          final tasks = filterTasks(
            snapshot.data ?? const <TaskModel>[],
            _filter,
          );
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
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
              ...tasks.map(
                (task) => taskTile(
                  context,
                  task,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManagerTaskDetailPage(task: task),
                        ),
                      ),
                ),
              ),
              if (tasks.isEmpty) emptyView('No tasks found.'),
            ],
          );
        },
      ),
    );
  }
}

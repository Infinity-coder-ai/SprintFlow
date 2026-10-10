import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/manager_update_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/manager_update_service.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';
import 'client_labels.dart';
import 'client_theme.dart';
import 'client_tiles.dart';
import 'client_widgets.dart';

class ClientProjectDetailsPage extends StatelessWidget {
  final ProjectModel project;
  final UserModel client;
  const ClientProjectDetailsPage({
    super.key,
    required this.project,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectModel?>(
      stream: ProjectService().streamClientProject(project.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project Details')),
            body: Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load project: ${snapshot.error}'),
            ),
          );
        }
        final current = snapshot.data ?? project;
        return Scaffold(
          appBar: AppBar(title: const Text('Project Details')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ClientColors.purple.withOpacity(.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: ClientColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      current.title,
                      style: const TextStyle(
                        color: ClientColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  projectStatusPill(current.status),
                ],
              ),
              const SizedBox(height: 20),
              darkCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: ClientColors.purpleLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        current.description.isEmpty
                            ? 'No description.'
                            : current.description,
                        style: const TextStyle(color: ClientColors.white),
                      ),
                      if (current.expectedFinish != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Due ${formatDate(current.expectedFinish!)}',
                          style: const TextStyle(
                            color: ClientColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: (current.progressPercentage / 100).clamp(
                          0.0,
                          1.0,
                        ),
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          ClientColors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${current.progressPercentage.toInt()}% complete',
                        style: const TextStyle(color: ClientColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<TaskModel>>(
                stream: TaskService().streamTasksForProject(current.id),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.hasError) {
                    return errorCard(
                      'Couldn\'t load tasks: ${taskSnapshot.error}',
                    );
                  }
                  final tasks = taskSnapshot.data ?? const <TaskModel>[];
                  final done =
                      tasks
                          .where((t) => t.status == AppConstants.statusDone)
                          .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: detailStat('Tasks', '${tasks.length}'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: detailStat('Completed', '$done')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: detailStat(
                              'Team',
                              '${current.assignedEmployees.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Task Progress',
                        style: TextStyle(
                          color: ClientColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (tasks.isEmpty)
                        emptyView('No tasks posted on this project yet.')
                      else
                        ...tasks.map(clientTaskTile),
                      const SizedBox(height: 22),
                      const Text(
                        'Manager Updates',
                        style: TextStyle(
                          color: ClientColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<List<ManagerUpdateModel>>(
                        stream: ManagerUpdateService().streamUpdatesForClient(
                          client.id,
                          clientEmail: client.email,
                        ),
                        builder: (context, updateSnapshot) {
                          if (updateSnapshot.hasError) {
                            return errorCard(
                              'Couldn\'t load updates: ${updateSnapshot.error}',
                            );
                          }
                          final updates =
                              (updateSnapshot.data ??
                                      const <ManagerUpdateModel>[])
                                  .where((u) => u.projectId == current.id)
                                  .toList();
                          if (updates.isEmpty) {
                            return emptyView(
                              'No updates posted for this project yet.',
                            );
                          }
                          return Column(
                            children: updates.map(updateTile).toList(),
                          );
                        },
                      ),
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

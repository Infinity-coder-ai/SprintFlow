import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import 'manager_create_project_page.dart';
import 'manager_logic.dart';
import 'manager_project_details_page.dart';
import 'manager_projects_page.dart';
import 'manager_progress_card.dart';
import 'manager_status_card.dart';
import 'manager_team_hours_card.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerHomePage extends StatelessWidget {
  final UserModel manager;
  const ManagerHomePage({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForManager(manager.id),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? const <ProjectModel>[];
        final tasksFuture = loadTasksForProjects(projects);
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => loadTasksForProjects(projects),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                topBar(
                  context,
                  'Home',
                  Icons.dashboard_outlined,
                  action: Icons.add,
                  onAction:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ManagerCreateProjectPage(manager: manager),
                        ),
                      ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Hi, ${manager.name}',
                  style: const TextStyle(
                    color: ManagerColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<TaskModel>>(
                  future: tasksFuture,
                  builder: (context, taskSnapshot) {
                    final tasks = taskSnapshot.data ?? const <TaskModel>[];
                    final members =
                        projects
                            .expand((p) => p.assignedEmployees)
                            .toSet()
                            .length;
                    final pending =
                        projects
                            .where((p) => p.progressPercentage <= 0)
                            .length;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                      children: [
                        metric(
                          'Projects',
                          '${projects.length}',
                          Icons.folder_outlined,
                          ManagerColors.purpleLight,
                        ),
                        metric(
                          'Tasks',
                          '${tasks.length}',
                          Icons.check_box_outlined,
                          ManagerColors.green,
                        ),
                        metric(
                          'Team Members',
                          '$members',
                          Icons.groups_outlined,
                          Colors.cyanAccent,
                        ),
                        metric(
                          'Pending',
                          '$pending',
                          Icons.pending_actions,
                          ManagerColors.orange,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                sectionTitle(context, 'Overall Progress'),
                progressCard(projects),
                const SizedBox(height: 20),
                sectionTitle(context, 'Task Status'),
                ManagerTaskStatusCard(tasksFuture: tasksFuture),
                const SizedBox(height: 20),
                sectionTitle(context, 'Team Hours This Week'),
                ManagerTeamHoursCard(
                  projectIds: projects.map((p) => p.id).toList(),
                ),
                const SizedBox(height: 20),
                sectionTitle(
                  context,
                  'Recent Projects',
                  action: 'View all',
                  onAction:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Scaffold(
                                backgroundColor: ManagerColors.ink,
                                body: ManagerProjectsPage(manager: manager),
                              ),
                        ),
                      ),
                ),
                ...projects.take(3).map(
                  (project) => projectTile(
                    context,
                    project,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ManagerProjectDetailsPage(
                                  project: project,
                                ),
                          ),
                        ),
                  ),
                ),
                if (projects.isEmpty)
                  emptyView('Create your first project to get started.'),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget metric(String label, String value, IconData icon, Color color) =>
    darkCard(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Text(
              value,
              style: const TextStyle(
                color: ManagerColors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: ManagerColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

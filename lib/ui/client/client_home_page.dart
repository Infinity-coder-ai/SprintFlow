import 'package:flutter/material.dart';

import '../../database/models/manager_update_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/manager_update_service.dart';
import '../../database/services/project_service.dart';
import 'client_logic.dart';
import 'client_project_details_page.dart';
import 'client_projects_page.dart';
import 'client_progress_ring.dart';
import 'client_theme.dart';
import 'client_tiles.dart';
import 'client_updates_page.dart';
import 'client_widgets.dart';

class ClientHomePage extends StatelessWidget {
  final UserModel client;
  const ClientHomePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().getClientProjectsStreamByIdOrEmail(
        client.id,
        client.email,
      ),
      builder: (context, projectSnapshot) {
        final projects = visibleProjects(
          projectSnapshot.data ?? const <ProjectModel>[],
        );
        return StreamBuilder<List<ManagerUpdateModel>>(
          stream: ManagerUpdateService().streamUpdatesForClient(
            client.id,
            clientEmail: client.email,
          ),
          builder: (context, updateSnapshot) {
            if (updateSnapshot.hasError) {
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  children: [
                    topBar(context, 'Home', Icons.dashboard_outlined),
                    const SizedBox(height: 14),
                    errorCard(
                      'Couldn\'t load updates: ${updateSnapshot.error}',
                    ),
                  ],
                ),
              );
            }
            final updates = updateSnapshot.data ?? const <ManagerUpdateModel>[];
            final completed = completedCount(projects);
            final avg = averageProgress(projects);
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  topBar(context, 'Home', Icons.dashboard_outlined),
                  if (projectSnapshot.hasError)
                    errorCard(
                      'Couldn\'t load projects: ${projectSnapshot.error}',
                    ),
                  const SizedBox(height: 18),
                  Text(
                    'Hi, ${client.companyName ?? client.name}',
                    style: const TextStyle(
                      color: ClientColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [
                      metric(
                        'My Projects',
                        '${projects.length}',
                        Icons.folder_outlined,
                        ClientColors.purpleLight,
                      ),
                      metric(
                        'Completed',
                        '$completed',
                        Icons.check_circle_outline,
                        ClientColors.green,
                      ),
                      metric(
                        'Updates',
                        '${updates.length}',
                        Icons.campaign_outlined,
                        ClientColors.orange,
                      ),
                      metric(
                        'Avg Progress',
                        '${avg.toInt()}%',
                        Icons.trending_up_outlined,
                        Colors.cyanAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  sectionTitle(context, 'Overall Progress'),
                  ClientProgressRing(
                    average: avg,
                    completed: completed,
                    total: projects.length,
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
                                  backgroundColor: ClientColors.ink,
                                  body: ClientProjectsPage(client: client),
                                ),
                          ),
                        ),
                  ),
                  ...projects
                      .take(3)
                      .map(
                        (project) => projectTile(
                          context,
                          project,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ClientProjectDetailsPage(
                                        project: project,
                                        client: client,
                                      ),
                                ),
                              ),
                        ),
                      ),
                  if (projects.isEmpty)
                    emptyView('No projects shared with you yet.'),
                  const SizedBox(height: 20),
                  sectionTitle(
                    context,
                    'Latest Updates',
                    action: 'View all',
                    onAction:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Scaffold(
                                  backgroundColor: ClientColors.ink,
                                  body: ClientUpdatesPage(client: client),
                                ),
                          ),
                        ),
                  ),
                  if (updates.isEmpty)
                    emptyView('No updates from your manager yet.')
                  else
                    ...updates.take(3).map(updateTile),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

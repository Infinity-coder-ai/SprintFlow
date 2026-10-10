import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../business_logic/providers/auth_provider.dart';
import '../../database/services/project_service.dart';
import 'manager_invite_page.dart';
import 'manager_project_tasks_page.dart';
import 'manager_project_team_page.dart';
import 'manager_project_update_page.dart';
import 'manager_labels.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerProjectDetailsPage extends StatelessWidget {
  final ProjectModel project;
  const ManagerProjectDetailsPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) => StreamBuilder<ProjectModel?>(
    stream: ProjectService().streamProject(project.id),
    builder: (context, snapshot) {
      final current = snapshot.data ?? project;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Project Details'),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ManagerColors.purple.withOpacity(.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: ManagerColors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    current.title,
                    style: const TextStyle(
                      color: ManagerColors.white,
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
                        color: ManagerColors.purpleLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      current.description,
                      style: const TextStyle(color: ManagerColors.white),
                    ),
                    const SizedBox(height: 18),
                    LinearProgressIndicator(
                      value: (current.progressPercentage / 100).clamp(
                        0.0,
                        1.0,
                      ),
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                        ManagerColors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${current.progressPercentage.toInt()}% complete',
                      style: const TextStyle(color: ManagerColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: detailStat('Tasks', '${current.totalTasks}'),
                ),
                Expanded(
                  child: detailStat(
                    'Completed',
                    '${current.completedTasks}',
                  ),
                ),
                Expanded(
                  child: detailStat(
                    'Members',
                    '${current.assignedEmployees.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            actionTile(
              context,
              'Tasks',
              Icons.check_box_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerProjectTasksPage(project: current),
                ),
              ),
            ),
            actionTile(
              context,
              'Team',
              Icons.groups_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerProjectTeamPage(project: current),
                ),
              ),
            ),
            actionTile(
              context,
              'Updates',
              Icons.campaign_outlined,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerProjectUpdatePage(project: current),
                ),
              ),
            ),
            actionTile(
              context,
              'Invite Member',
              Icons.person_add_alt_1,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ManagerInvitePage(
                        manager: context.read<AuthProvider>().userData!,
                        projectId: current.id,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget detailStat(String label, String value) => darkCard(
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: ManagerColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: ManagerColors.muted, fontSize: 11),
        ),
      ],
    ),
  ),
);

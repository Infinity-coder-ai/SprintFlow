import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import 'manager_project_update_page.dart';
import 'manager_theme.dart';
import 'manager_widgets.dart';

class ManagerUpdatesPage extends StatelessWidget {
  final UserModel manager;
  const ManagerUpdatesPage({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().streamProjectsForManager(manager.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project Updates')),
            body: Padding(
              padding: const EdgeInsets.all(18),
              child: errorCard('Couldn\'t load projects: ${snapshot.error}'),
            ),
          );
        }
        final projects = snapshot.data ?? const <ProjectModel>[];
        return Scaffold(
          appBar: AppBar(title: const Text('Project Updates')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children:
                projects
                    .map(
                      (project) => darkCard(
                        child: ListTile(
                          leading: const Icon(
                            Icons.campaign_outlined,
                            color: ManagerColors.purpleLight,
                          ),
                          title: Text(
                            project.title,
                            style: const TextStyle(
                              color: ManagerColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Open client updates',
                            style: TextStyle(color: ManagerColors.muted),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: ManagerColors.muted,
                          ),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ManagerProjectUpdatePage(
                                        project: project,
                                      ),
                                ),
                              ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}

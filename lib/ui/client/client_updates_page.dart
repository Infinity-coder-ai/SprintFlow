import 'package:flutter/material.dart';

import '../../database/models/manager_update_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/manager_update_service.dart';
import '../../database/services/project_service.dart';
import 'client_theme.dart';
import 'client_tiles.dart';
import 'client_widgets.dart';

class ClientUpdatesPage extends StatelessWidget {
  final UserModel client;
  const ClientUpdatesPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().getClientProjectsStreamByIdOrEmail(
        client.id,
        client.email,
      ),
      builder: (context, projectSnapshot) {
        final names = {
          for (final p in projectSnapshot.data ?? const <ProjectModel>[])
            p.id: p.title,
        };
        return StreamBuilder<List<ManagerUpdateModel>>(
          stream: ManagerUpdateService().streamUpdatesForClient(
            client.id,
            clientEmail: client.email,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  children: [
                    topBar(context, 'Updates', Icons.campaign_outlined),
                    const SizedBox(height: 14),
                    errorCard('Couldn\'t load updates: ${snapshot.error}'),
                  ],
                ),
              );
            }
            final updates = snapshot.data ?? const <ManagerUpdateModel>[];
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  topBar(context, 'Updates', Icons.campaign_outlined),
                  if (projectSnapshot.hasError)
                    errorCard(
                      'Couldn\'t load projects: ${projectSnapshot.error}',
                    ),
                  const SizedBox(height: 14),
                  if (updates.isEmpty)
                    emptyView('No updates from your manager yet.')
                  else
                    ...updates.map(
                      (update) => updateTileWithProject(
                        update,
                        names[update.projectId] ?? 'Project',
                      ),
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

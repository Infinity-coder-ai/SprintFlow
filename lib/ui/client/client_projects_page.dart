import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import 'client_logic.dart';
import 'client_project_details_page.dart';
import 'client_theme.dart';
import 'client_tiles.dart';
import 'client_widgets.dart';

class ClientProjectsPage extends StatefulWidget {
  final UserModel client;
  const ClientProjectsPage({super.key, required this.client});

  @override
  State<ClientProjectsPage> createState() => _ClientProjectsPageState();
}

class _ClientProjectsPageState extends State<ClientProjectsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectModel>>(
      stream: ProjectService().getClientProjectsStreamByIdOrEmail(
        widget.client.id,
        widget.client.email,
      ),
      builder: (context, snapshot) {
        final projects = searchProjects(
          snapshot.data ?? const <ProjectModel>[],
          _search.text,
        );
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              topBar(context, 'My Projects', Icons.folder_outlined),
              if (snapshot.hasError)
                errorCard('Couldn\'t load projects: ${snapshot.error}'),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: ClientColors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: ClientColors.muted),
                  hintText: 'Search projects...',
                ),
              ),
              const SizedBox(height: 14),
              ...projects.map(
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
                                client: widget.client,
                              ),
                        ),
                      ),
                ),
              ),
              if (projects.isEmpty) emptyView('No projects found.'),
            ],
          ),
        );
      },
    );
  }
}

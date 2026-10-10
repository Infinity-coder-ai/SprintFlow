import 'package:flutter/material.dart';

import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_service.dart';
import 'manager_create_project_page.dart';
import 'manager_logic.dart';
import 'manager_project_details_page.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerProjectsPage extends StatefulWidget {
  final UserModel manager;
  const ManagerProjectsPage({super.key, required this.manager});

  @override
  State<ManagerProjectsPage> createState() => _ManagerProjectsPageState();
}

class _ManagerProjectsPageState extends State<ManagerProjectsPage> {
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
      stream: ProjectService().streamProjectsForManager(widget.manager.id),
      builder: (context, snapshot) {
        final projects = filterProjects(
          snapshot.data ?? const <ProjectModel>[],
          _search.text,
          _filter,
        );
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              topBar(
                context,
                'Projects',
                Icons.folder_outlined,
                action: Icons.add,
                onAction:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ManagerCreateProjectPage(
                              manager: widget.manager,
                            ),
                      ),
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: ManagerColors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: ManagerColors.muted),
                  hintText: 'Search projects...',
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['All', 'Active', 'Completed', 'On Hold'].map((label) {
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
              ...projects.map(
                (project) => projectTile(
                  context,
                  project,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  ManagerProjectDetailsPage(project: project),
                        ),
                      ),
                ),
              ),
              if (projects.isEmpty) emptyView('No projects created yet.'),
            ],
          ),
        );
      },
    );
  }
}

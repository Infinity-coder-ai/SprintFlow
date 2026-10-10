import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/project_model.dart';
import '../../database/models/user_model.dart';
import '../../business_logic/providers/auth_provider.dart';
import '../../database/services/firebase_service.dart';
import '../../database/services/project_service.dart';
import 'manager_forms.dart';
import 'manager_invite_page.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerProjectTeamPage extends StatelessWidget {
  final ProjectModel project;
  const ManagerProjectTeamPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectModel?>(
      stream: ProjectService().streamProject(project.id),
      builder: (context, snapshot) {
        final current = snapshot.data ?? project;
        return Scaffold(
          appBar: AppBar(title: const Text('Team Members')),
          body: FutureBuilder<List<UserModel>>(
            future: Future.wait(
              current.assignedEmployees.map(FirebaseService.getUserData),
            ).then((items) => items.whereType<UserModel>().toList()),
            builder: (context, employeeSnapshot) {
              final employees = employeeSnapshot.data ?? const <UserModel>[];
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  primaryButton(
                    'Invite Member',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ManagerInvitePage(
                              manager:
                                  context.read<AuthProvider>().userData!,
                              projectId: current.id,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...employees.map(employeeTile),
                  if (employees.isEmpty)
                    emptyView('No members assigned to this project.'),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

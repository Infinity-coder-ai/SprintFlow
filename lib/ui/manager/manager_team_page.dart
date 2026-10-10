import 'package:flutter/material.dart';

import '../../database/models/user_model.dart';
import '../../database/services/firebase_service.dart';
import 'manager_invite_page.dart';
import 'manager_theme.dart';
import 'manager_tiles.dart';
import 'manager_widgets.dart';

class ManagerTeamPage extends StatelessWidget {
  final UserModel manager;
  const ManagerTeamPage({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<UserModel>>(
        stream: FirebaseService.getManagedUsers(manager.id),
        builder: (context, snapshot) {
          final employees = snapshot.data ?? const <UserModel>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              topBar(
                context,
                'Team Members',
                Icons.groups_outlined,
                action: Icons.person_add_alt_1,
                onAction:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManagerInvitePage(manager: manager),
                      ),
                    ),
              ),
              const SizedBox(height: 14),
              ...employees.map(employeeTile),
              if (employees.isEmpty)
                emptyView(
                  'No team members yet. Invite an employee to a project.',
                ),
            ],
          );
        },
      ),
    );
  }
}

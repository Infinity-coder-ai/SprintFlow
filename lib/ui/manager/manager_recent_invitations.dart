import 'package:flutter/material.dart';

import '../../database/models/project_invitation_model.dart';
import '../../database/services/project_invitation_service.dart';
import 'manager_logic.dart';
import 'manager_tiles.dart';

/// Latest invitation activity for the invite screen.
class ManagerRecentInvitations extends StatelessWidget {
  final String managerId;
  const ManagerRecentInvitations({super.key, required this.managerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectInvitationModel>>(
      stream: ProjectInvitationService().streamInvitationsForManager(managerId),
      builder: (context, invitationSnapshot) => Column(
        children:
            dedupeInvitations(
              invitationSnapshot.data ?? const <ProjectInvitationModel>[],
            ).take(5).map(invitationRow).toList(),
      ),
    );
  }
}

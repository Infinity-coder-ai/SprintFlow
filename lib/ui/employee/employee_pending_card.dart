import 'package:flutter/material.dart';

import '../../database/models/project_invitation_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_invitation_service.dart';
import 'employee_invitations_page.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Banner linking to pending invitations; hidden when there are none.
class EmployeePendingCard extends StatelessWidget {
  final UserModel employee;
  const EmployeePendingCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProjectInvitationModel>>(
      stream: ProjectInvitationService().streamInvitationsForEmployee(
        employee.id,
      ),
      builder: (context, snapshot) {
        final pending =
            (snapshot.data ?? const <ProjectInvitationModel>[])
                .where((i) => i.isPending)
                .length;
        if (pending == 0) return const SizedBox.shrink();
        return darkCard(
          child: ListTile(
            leading: const Icon(
              Icons.mark_email_unread_outlined,
              color: EmployeeColors.purpleLight,
            ),
            title: Text(
              '$pending pending invitation${pending == 1 ? '' : 's'}',
              style: const TextStyle(
                color: EmployeeColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'Review and respond',
              style: TextStyle(color: EmployeeColors.muted),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: EmployeeColors.muted,
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => Scaffold(
                          backgroundColor: EmployeeColors.ink,
                          body: EmployeeInvitationsPage(employee: employee),
                        ),
                  ),
                ),
          ),
        );
      },
    );
  }
}

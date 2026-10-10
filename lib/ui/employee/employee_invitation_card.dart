import 'package:flutter/material.dart';

import '../../database/models/project_invitation_model.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

/// Accept/reject card for a single project invitation.
class EmployeeInvitationCard extends StatelessWidget {
  final ProjectInvitationModel invitation;
  final bool working;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const EmployeeInvitationCard({
    super.key,
    required this.invitation,
    required this.working,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return darkCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invitation.projectTitle,
              style: const TextStyle(
                color: EmployeeColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Invited by ${invitation.managerName}',
              style: const TextStyle(
                color: EmployeeColors.muted,
                fontSize: 13,
              ),
            ),
            Text(
              formatDate(invitation.createdAt),
              style: const TextStyle(
                color: EmployeeColors.muted,
                fontSize: 12,
              ),
            ),
            if (invitation.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: primaryButton(
                      working ? 'Working...' : 'Accept',
                      working ? null : onAccept,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: working ? null : onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: EmployeeColors.red,
                          side: const BorderSide(color: EmployeeColors.red),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: pill(
                  invitation.status.toUpperCase(),
                  invitation.isAccepted
                      ? EmployeeColors.green
                      : EmployeeColors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../database/models/project_invitation_model.dart';
import '../../database/models/user_model.dart';
import '../../database/services/project_invitation_service.dart';
import 'employee_invitation_card.dart';
import 'employee_logic.dart';
import 'employee_theme.dart';
import 'employee_widgets.dart';

class EmployeeInvitationsPage extends StatefulWidget {
  final UserModel employee;
  const EmployeeInvitationsPage({super.key, required this.employee});

  @override
  State<EmployeeInvitationsPage> createState() =>
      _EmployeeInvitationsPageState();
}

class _EmployeeInvitationsPageState extends State<EmployeeInvitationsPage> {
  String _filter = 'Pending';
  String? _workingId;

  @override
  Widget build(BuildContext context) {
    final inTab = Navigator.of(context).canPop();
    final body = StreamBuilder<List<ProjectInvitationModel>>(
      stream: ProjectInvitationService().streamInvitationsForEmployee(
        widget.employee.id,
      ),
      builder: (context, snapshot) {
        final invitations =
            dedupeInvitations(
              snapshot.data ?? const <ProjectInvitationModel>[],
            ).where((item) {
              switch (_filter) {
                case 'Accepted':
                  return item.isAccepted;
                case 'Rejected':
                  return item.isRejected;
                default:
                  return item.isPending;
              }
            }).toList();
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children:
                    ['Pending', 'Accepted', 'Rejected'].map((label) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          labelStyle: TextStyle(
                            color:
                                _filter == label
                                    ? EmployeeColors.white
                                    : EmployeeColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                          selected: _filter == label,
                          selectedColor: EmployeeColors.purple.withValues(alpha:
                            .35,
                          ),
                          onSelected:
                              (_) => setState(() => _filter = label),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Expanded(
              child:
                  invitations.isEmpty
                      ? emptyView('No $_filter invitations.')
                      : ListView.separated(
                        padding: const EdgeInsets.all(18),
                        itemCount: invitations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (context, index) => EmployeeInvitationCard(
                              invitation: invitations[index],
                              working:
                                  _workingId == invitations[index].id,
                              onAccept:
                                  () => _respond(
                                    invitations[index],
                                    AppConstants.projectInvitationStatusAccepted,
                                  ),
                              onReject:
                                  () => _respond(
                                    invitations[index],
                                    AppConstants.projectInvitationStatusRejected,
                                  ),
                            ),
                      ),
            ),
          ],
        );
      },
    );

    if (inTab) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project Invitations')),
        body: body,
      );
    }
    return SafeArea(child: body);
  }

  Future<void> _respond(ProjectInvitationModel invitation, String status) async {
    setState(() => _workingId = invitation.id);
    try {
      await ProjectInvitationService().respondToInvitation(
        invitationId: invitation.id,
        employeeId: widget.employee.id,
        status: status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == AppConstants.projectInvitationStatusAccepted
                  ? 'Invitation accepted'
                  : 'Invitation rejected',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _workingId = null);
    }
  }
}

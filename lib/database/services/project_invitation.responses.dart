part of 'project_invitation_service.dart';

/// Accept/decline handling. Same library as [ProjectInvitationService],
/// so every existing call site keeps working without new imports.
extension InvitationResponses on ProjectInvitationService {
  Future<void> respondToInvitation({
    required String invitationId,
    required String employeeId,
    required String status,
  }) async {
    final invitationDoc = _invitations.doc(invitationId);
    final invitation = await invitationDoc.get();

    if (!invitation.exists) {
      throw Exception('Invitation not found');
    }

    final data = invitation.data() ?? <String, dynamic>{};
    if (data['employeeId'] != employeeId) {
      throw Exception('You are not allowed to respond to this invitation');
    }

    await invitationDoc.update({
      'status': status,
      'respondedAt': FieldValue.serverTimestamp(),
    });

    final projectId = data['projectId'] as String? ?? '';
    final projectTitle = data['projectTitle'];
    final managerId = data['managerId'];

    if (status == AppConstants.projectInvitationStatusAccepted &&
        projectId.isNotEmpty) {
      await _addEmployeeToProject(projectId, employeeId);
    }

    await createNotification(
      userId: managerId,
      type: AppConstants.notificationProjectInvitationResponse,
      title: 'Invitation response',
      message:
          '${data['employeeName']} ${status == AppConstants.projectInvitationStatusAccepted ? 'accepted' : 'declined'} your invitation to "$projectTitle".',
      extra: {'projectId': projectId, 'invitationId': invitationId},
    );
  }

  Future<void> _addEmployeeToProject(
    String projectId,
    String employeeId,
  ) async {
    final payload = {
      'assignedEmployees': FieldValue.arrayUnion([employeeId]),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _db
        .collection(AppConstants.collectionManagersProjects)
        .doc(projectId)
        .update(payload);

    try {
      await _db
          .collection(AppConstants.collectionClientsProjects)
          .doc(projectId)
          .update(payload);
    } catch (_) {}

    await _db.collection(AppConstants.collectionUsers).doc(employeeId).update({
      'assignedProjects': FieldValue.arrayUnion([projectId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

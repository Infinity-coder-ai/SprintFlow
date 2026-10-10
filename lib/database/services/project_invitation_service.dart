import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/project_invitation_model.dart';

part 'project_invitation.responses.dart';

class ProjectInvitationService {
  final FirebaseFirestore _db;

  ProjectInvitationService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _db.collection(AppConstants.collectionProjectInvitations);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection(AppConstants.collectionNotifications);

  String invitationDocId(String projectId, String employeeId) =>
      '${projectId}_$employeeId';

  Future<String> sendInvitation({
    required String projectId,
    required String projectTitle,
    required String managerId,
    required String managerName,
    required String employeeId,
    required String employeeEmail,
    required String employeeName,
  }) async {
    final invitationId = invitationDocId(projectId, employeeId);
    final invitationRef = _invitations.doc(invitationId);
    // Existence check via query: a direct .get() on a missing doc is denied
    // by the read rule (it dereferences resource.data), while an empty
    // query result is allowed.
    final existingQuery =
        await _invitations
            .where(FieldPath.documentId, isEqualTo: invitationId)
            .limit(1)
            .get();

    if (existingQuery.docs.isNotEmpty) {
      final status = existingQuery.docs.first.data()['status'];
      if (status == AppConstants.projectInvitationStatusPending) {
        throw Exception('An invitation is already pending for this employee.');
      }
      if (status == AppConstants.projectInvitationStatusAccepted) {
        throw Exception(
          'This employee has already accepted an invitation to this project.',
        );
      }
    }

    final invitation = ProjectInvitationModel(
      id: invitationId,
      projectId: projectId,
      projectTitle: projectTitle,
      managerId: managerId,
      managerName: managerName,
      employeeId: employeeId,
      employeeEmail: employeeEmail,
      employeeName: employeeName,
      status: AppConstants.projectInvitationStatusPending,
      createdAt: DateTime.now(),
    );

    await invitationRef.set(invitation.toFirestore());

    await createNotification(
      userId: employeeId,
      type: AppConstants.notificationProjectInvitation,
      title: 'Project invitation',
      message: '$managerName invited you to join "$projectTitle".',
      extra: {'projectId': projectId, 'invitationId': invitationId},
    );

    return invitationId;
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic> extra = const {},
  }) async {
    await _notifications.add({
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...extra,
    });
  }

  Stream<List<ProjectInvitationModel>> streamInvitationsForEmployee(
    String employeeId,
  ) {
    if (employeeId.isEmpty) return Stream.value(const <ProjectInvitationModel>[]);
    return _invitations
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectInvitationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Stream<List<ProjectInvitationModel>> streamInvitationsForManager(
    String managerId,
  ) {
    if (managerId.isEmpty) return Stream.value(const <ProjectInvitationModel>[]);
    return _invitations
        .where('managerId', isEqualTo: managerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectInvitationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Stream<List<ProjectInvitationModel>> streamInvitationsForProject(
    String projectId,
  ) {
    if (projectId.isEmpty) return Stream.value(const <ProjectInvitationModel>[]);
    return _invitations
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProjectInvitationModel.fromFirestore(doc))
                  .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamNotificationsForUser(
    String userId,
  ) {
    if (userId.isEmpty) return Stream.value(const <Map<String, dynamic>>[]);
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({
      'isRead': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

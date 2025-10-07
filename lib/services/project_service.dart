import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/project_model.dart';
import 'task_service.dart';
import 'work_update_service.dart';
import 'manager_update_service.dart';

class ProjectService {
  final FirebaseFirestore _db;
  ProjectService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _mgrProjects => _db.collection(AppConstants.collectionManagersProjects);
  CollectionReference<Map<String, dynamic>> get _clientProjects => _db.collection(AppConstants.collectionClientsProjects);

  Stream<List<ProjectModel>> streamProjectsForManager(String managerId) {
    return _mgrProjects
        .where('managerId', isEqualTo: managerId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList());
  }

  Future<String> createProject({
    required String title,
    required String description,
    required String managerId,
    String? clientId,
    String? clientEmail,
    DateTime? expectedFinish,
    List<String> assignedEmployees = const [],
  }) async {
    final doc = _mgrProjects.doc();
    final now = DateTime.now();
    final model = ProjectModel(
      id: doc.id,
      title: title,
      description: description,
      status: AppConstants.projectStatusDraft,
      managerId: managerId,
      clientId: clientId ?? '',
      createdAt: now,
      expectedFinish: expectedFinish,
      assignedEmployees: assignedEmployees,
      isPublic: true,
      isArchived: false,
      progressPercentage: 0,
      totalTasks: 0,
      completedTasks: 0,
      overdueTasks: 0,
    );
    final mgrData = model.toFirestore();
    if (clientEmail != null && clientEmail.isNotEmpty) {
      mgrData['clientEmail'] = clientEmail;
    }
    if (clientId != null && clientId.isNotEmpty) {
      mgrData['clientId'] = clientId;
    }
    await doc.set(mgrData);
    // Create client-safe mirror
    final clientDoc = _clientProjects.doc(doc.id);
    final clientKeys = <String>[];
    if (clientId != null && clientId.isNotEmpty) clientKeys.add(clientId);
    if (clientEmail != null && clientEmail.isNotEmpty) clientKeys.add(clientEmail);
    await clientDoc.set({
      'id': doc.id,
      'title': title,
      'description': description,
      'clientId': clientId,
      'clientEmail': clientEmail,
      'clientKeys': clientKeys,
      'managerId': managerId,
      'createdAt': Timestamp.fromDate(now),
      'expectedFinish': expectedFinish != null ? Timestamp.fromDate(expectedFinish) : null,
      'progressPercentage': 0,
      'totalTasks': 0,
      'completedTasks': 0,
      'overdueTasks': 0,
      'status': AppConstants.projectStatusDraft,
      // no employee names, no internal details
    });
    return doc.id;
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _mgrProjects.doc(projectId).update(data);
    // Sync client mirror for allowed fields
    final mirror = <String, dynamic>{};
    for (final key in ['title','description','expectedFinish','progressPercentage','totalTasks','completedTasks','overdueTasks','status']) {
      if (data.containsKey(key)) mirror[key] = data[key];
    }
    if (mirror.isNotEmpty) {
      await _clientProjects.doc(projectId).update(mirror);
    }
  }

  Future<void> archiveProject(String projectId) async {
    await _mgrProjects.doc(projectId).update({'isArchived': true, 'status': AppConstants.projectStatusArchived, 'updatedAt': FieldValue.serverTimestamp()});
    await _clientProjects.doc(projectId).update({'status': AppConstants.projectStatusArchived});
  }

  Future<void> deleteProject(String projectId) async {
    // Delete all tasks for this project
    final taskService = TaskService();
    await taskService.deleteAllTasksForProject(projectId);
    
    // Delete all work updates for this project
    final workUpdateService = WorkUpdateService();
    await workUpdateService.deleteWorkUpdatesForProject(projectId);
    // Delete all manager updates for this project
    final managerUpdateService = ManagerUpdateService();
    await managerUpdateService.deleteUpdatesForProject(projectId);
    
    // Delete from both project collections
    await Future.wait([
      _mgrProjects.doc(projectId).delete(),
      _clientProjects.doc(projectId).delete(),
    ]);
  }

  Future<void> assignEmployees(String projectId, List<String> employeeIds) async {
    await _mgrProjects.doc(projectId).update({
      'assignedEmployees': FieldValue.arrayUnion(employeeIds),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _mgrProjects.doc(projectId).get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  Stream<List<ProjectModel>> getClientProjectsStreamByIdOrEmail(String clientId, String email) {
    return _clientProjects
        .where('clientKeys', arrayContainsAny: [clientId, email])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList());
  }
}

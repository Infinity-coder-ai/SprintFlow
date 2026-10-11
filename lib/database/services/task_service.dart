import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/task_model.dart';
import 'project_invitation_service.dart';
import 'project_service.dart';
import 'work_update_service.dart';

part 'task_service.progress.dart';
part 'task_service.maintenance.dart';

class TaskService {
  final FirebaseFirestore _db;
  TaskService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _mgrTasks =>
      _db.collection(AppConstants.collectionManagersTasks);
  CollectionReference<Map<String, dynamic>> get _empTasks =>
      _db.collection(AppConstants.collectionEmployeesTasks);

  Stream<List<TaskModel>> streamTasksForProject(String projectId) {
    if (projectId.isEmpty) return Stream.value(const <TaskModel>[]);
    return _mgrTasks
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => TaskModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<TaskModel>> streamTasksForAssignee(String userId) {
    if (userId.isEmpty) return Stream.value(const <TaskModel>[]);
    return _empTasks
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => TaskModel.fromFirestore(d)).toList(),
        );
  }

  Future<String> createTask({
    required String title,
    required String description,
    required String projectId,
    required String createdBy,
    String? assignedTo,
    String priority = AppConstants.priorityMedium,
    DateTime? deadline,
  }) async {
    final doc = _mgrTasks.doc();
    final now = DateTime.now();
    final model = TaskModel(
      id: doc.id,
      title: title,
      description: description,
      status: AppConstants.statusTodo,
      priority: priority,
      projectId: projectId,
      assignedTo: assignedTo,
      createdBy: createdBy,
      createdAt: now,
      deadline: deadline,
      subtasks: const [],
      attachments: const [],
      tags: const [],
      progressPercentage: 0,
    );
    await doc.set(model.toFirestore());
    if (assignedTo != null && assignedTo.isNotEmpty) {
      await _empTasks.doc(doc.id).set(model.toFirestore());
      await ProjectInvitationService().createNotification(
        userId: assignedTo,
        type: AppConstants.notificationTaskAssigned,
        title: 'Task assigned',
        message: 'You were assigned "$title".',
        extra: {'projectId': projectId, 'taskId': doc.id},
      );
    }
    await _recalculateProjectStats(projectId);
    return doc.id;
  }

  Future<void> completeTask(String taskId) async {
    final payload = {
      'status': AppConstants.statusDone,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _mgrTasks.doc(taskId).update(payload);
    try {
      await _empTasks.doc(taskId).update(payload);
    } catch (_) {}
  }

  Future<void> moveTaskStatus(String taskId, String status) async {
    final payload = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _mgrTasks.doc(taskId).update(payload);
    try {
      await _empTasks.doc(taskId).update(payload);
    } catch (_) {}
  }

  Future<List<TaskModel>> getTasksForProjectAsync(String projectId) async {
    final querySnapshot =
        await _mgrTasks
            .where('projectId', isEqualTo: projectId)
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import 'project_service.dart';
import 'work_update_service.dart';

class TaskService {
  final FirebaseFirestore _db;
  TaskService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _mgrTasks => _db.collection(AppConstants.collectionManagersTasks);
  CollectionReference<Map<String, dynamic>> get _empTasks => _db.collection(AppConstants.collectionEmployeesTasks);

  Stream<List<TaskModel>> streamTasksForProject(String projectId) {
    return _mgrTasks
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  Stream<List<TaskModel>> streamTasksForAssignee(String userId) {
    return _empTasks
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
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
    // Mirror to employee tasks if assigned
    if (assignedTo != null && assignedTo.isNotEmpty) {
      await _empTasks.doc(doc.id).set({
        ...model.toFirestore(),
      });
    }
    return doc.id;
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _mgrTasks.doc(taskId).update(data);
    if (data.containsKey('assignedTo')) {
      // move mirror if reassigned
      final assignedTo = data['assignedTo'] as String?;
      await _empTasks.doc(taskId).delete().catchError((_){});
      if (assignedTo != null && assignedTo.isNotEmpty) {
        final current = await _mgrTasks.doc(taskId).get();
        if (current.exists) {
          await _empTasks.doc(taskId).set(current.data()!);
        }
      }
    } else {
      // sync basic fields
      await _empTasks.doc(taskId).update(data).catchError((_){});
    }
  }

  Future<void> completeTask(String taskId) async {
    await _mgrTasks.doc(taskId).update({
      'status': AppConstants.statusDone,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _empTasks.doc(taskId).update({
      'status': AppConstants.statusDone,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_){});
  }

  Future<void> moveTaskStatus(String taskId, String status) async {
    await _mgrTasks.doc(taskId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _empTasks.doc(taskId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_){});
  }

  Future<void> updateTaskProgress(String taskId, int progressPercentage, int workHours) async {
    // Derive status from progress
    String derivedStatus;
    if (progressPercentage >= 100) {
      derivedStatus = AppConstants.statusDone;
    } else if (progressPercentage > 0) {
      derivedStatus = AppConstants.statusInProgress;
    } else {
      derivedStatus = AppConstants.statusTodo;
    }

    await _mgrTasks.doc(taskId).update({
      'progressPercentage': progressPercentage.toDouble(),
      'actualHours': FieldValue.increment(workHours),
      'status': derivedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _empTasks.doc(taskId).update({
      'progressPercentage': progressPercentage.toDouble(),
      'actualHours': FieldValue.increment(workHours),
      'status': derivedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_){})
    ;

    // Recalculate and update project KPIs
    final taskDoc = await _mgrTasks.doc(taskId).get();
    if (taskDoc.exists) {
      final data = taskDoc.data() as Map<String, dynamic>;
      final String projectId = data['projectId'] ?? '';
      if (projectId.isNotEmpty) {
        await _recalculateProjectStats(projectId);
      }
    }
  }

  Future<void> _recalculateProjectStats(String projectId) async {
    final query = await _mgrTasks.where('projectId', isEqualTo: projectId).get();
    int total = 0;
    int completed = 0;
    int overdue = 0;
    double progressSum = 0;
    final now = DateTime.now();
    for (final d in query.docs) {
      final m = d.data();
      total += 1;
      final num p = (m['progressPercentage'] ?? 0) as num;
      progressSum += p.toDouble();
      final String status = (m['status'] ?? '') as String;
      if (status == AppConstants.statusDone || p.toDouble() >= 100) {
        completed += 1;
      }
      final Timestamp? deadlineTs = m['deadline'] as Timestamp?;
      if (deadlineTs != null) {
        final deadline = deadlineTs.toDate();
        if (deadline.isBefore(now) && (status != AppConstants.statusDone)) {
          overdue += 1;
        }
      }
    }

    final progressPercentage = total > 0 ? (progressSum / total).round() : 0;

    await ProjectService().updateProject(projectId, {
      'totalTasks': total,
      'completedTasks': completed,
      'overdueTasks': overdue,
      'progressPercentage': progressPercentage,
    });
  }

  Future<TaskModel?> getTask(String taskId) async {
    final doc = await _mgrTasks.doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  Future<List<TaskModel>> getTasksForProjectAsync(String projectId) async {
    final querySnapshot = await _mgrTasks
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  Future<void> deleteTask(String taskId) async {
    // Read task first to get project/assignee for cleanup and KPI recalculation
    final snapshot = await _mgrTasks.doc(taskId).get();
    final Map<String, dynamic>? original = snapshot.data();
    final String projectId = original != null ? (original['projectId'] ?? '') as String : '';
    final String? assignedTo = original != null ? original['assignedTo'] as String? : null;

    // Delete from both collections
    await Future.wait([
      _mgrTasks.doc(taskId).delete(),
      _empTasks.doc(taskId).delete(),
    ]);
    // Also delete any work updates for this task
    await WorkUpdateService().deleteWorkUpdatesForTask(taskId);

    // Recalculate project stats so dashboards update
    if (projectId.isNotEmpty) {
      await _recalculateProjectStats(projectId);
    }

    // If the assignee has no more tasks on this project, remove from project's assignedEmployees
    if (projectId.isNotEmpty && assignedTo != null && assignedTo.isNotEmpty) {
      final remainingForAssignee = await _mgrTasks
          .where('projectId', isEqualTo: projectId)
          .where('assignedTo', isEqualTo: assignedTo)
          .limit(1)
          .get();
      if (remainingForAssignee.docs.isEmpty) {
        await ProjectService().updateProject(projectId, {
          'assignedEmployees': FieldValue.arrayRemove([assignedTo]),
        });
      }
    }
  }

  Future<void> deleteAllTasksForProject(String projectId) async {
    // Get all tasks for the project
    final tasks = await getTasksForProjectAsync(projectId);
    
    // Delete each task
    for (final task in tasks) {
      await deleteTask(task.id);
    }
  }

  Future<void> unassignEmployeeFromProject(String projectId, String employeeId) async {
    // Find all tasks on this project assigned to the employee
    final query = await _mgrTasks
        .where('projectId', isEqualTo: projectId)
        .where('assignedTo', isEqualTo: employeeId)
        .get();

    for (final doc in query.docs) {
      // Setting assignedTo to null triggers mirror cleanup in updateTask
      await updateTask(doc.id, {'assignedTo': null});
    }

    // After unassigning, recalc project stats (task counts remain the same)
    await _recalculateProjectStats(projectId);
  }
}

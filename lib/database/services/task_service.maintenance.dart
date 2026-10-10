part of 'task_service.dart';

/// Deletion, cleanup, and aggregate maintenance for tasks.
extension TaskMaintenance on TaskService {
  Future<void> _recalculateProjectStats(String projectId) async {
    final query =
        await _mgrTasks.where('projectId', isEqualTo: projectId).get();
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
        if (deadline.isBefore(now) && status != AppConstants.statusDone) {
          overdue += 1;
        }
      }
    }

    final progressPercentage = total > 0 ? (progressSum / total).round() : 0;
    String projectStatus = AppConstants.projectStatusDraft;
    if (total > 0 && completed == total) {
      projectStatus = AppConstants.projectStatusComplete;
    } else if (progressPercentage > 0) {
      projectStatus = AppConstants.projectStatusInProgress;
    }

    await ProjectService().updateProject(projectId, {
      'totalTasks': total,
      'completedTasks': completed,
      'overdueTasks': overdue,
      'progressPercentage': progressPercentage,
      'status': projectStatus,
    });
  }

  Future<void> deleteTask(String taskId) async {
    final snapshot = await _mgrTasks.doc(taskId).get();
    final Map<String, dynamic>? original = snapshot.data();
    final String projectId =
        original != null ? (original['projectId'] ?? '') as String : '';
    final String? assignedTo =
        original != null ? original['assignedTo'] as String? : null;

    await Future.wait([
      _mgrTasks.doc(taskId).delete(),
      _empTasks.doc(taskId).delete(),
    ]);
    await WorkUpdateService().deleteWorkUpdatesForTask(taskId);

    if (projectId.isNotEmpty) {
      await _recalculateProjectStats(projectId);
    }

    if (projectId.isNotEmpty && assignedTo != null && assignedTo.isNotEmpty) {
      final remainingForAssignee =
          await _mgrTasks
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
    final tasks = await getTasksForProjectAsync(projectId);
    for (final task in tasks) {
      await deleteTask(task.id);
    }
  }

  Future<void> unassignEmployeeFromProject(
    String projectId,
    String employeeId,
  ) async {
    final query =
        await _mgrTasks
            .where('projectId', isEqualTo: projectId)
            .where('assignedTo', isEqualTo: employeeId)
            .get();

    for (final doc in query.docs) {
      await updateTask(doc.id, {'assignedTo': null});
    }

    await _recalculateProjectStats(projectId);
  }
}

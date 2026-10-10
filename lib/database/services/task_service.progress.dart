part of 'task_service.dart';

/// Progress reporting: derives task status from reported progress and
/// refreshes the parent project's aggregate stats.
extension TaskProgress on TaskService {
  Future<void> updateTaskProgress(
    String taskId,
    int progressPercentage,
    int workHours,
  ) async {
    String derivedStatus;
    if (progressPercentage >= 100) {
      derivedStatus = AppConstants.statusDone;
    } else if (progressPercentage > 0) {
      derivedStatus = AppConstants.statusInProgress;
    } else {
      derivedStatus = AppConstants.statusTodo;
    }

    final payload = {
      'progressPercentage': progressPercentage.toDouble(),
      'actualHours': FieldValue.increment(workHours),
      'status': derivedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (derivedStatus == AppConstants.statusDone) {
      payload['completedAt'] = FieldValue.serverTimestamp();
    }

    await _mgrTasks.doc(taskId).update(payload);
    try {
      await _empTasks.doc(taskId).update(payload);
    } catch (_) {}

    final taskDoc = await _mgrTasks.doc(taskId).get();
    if (taskDoc.exists) {
      final data = taskDoc.data() ?? <String, dynamic>{};
      final String projectId = data['projectId'] ?? '';
      if (projectId.isNotEmpty) {
        await _recalculateProjectStats(projectId);
      }
    }
  }
}

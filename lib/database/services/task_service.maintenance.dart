part of 'task_service.dart';

/// Aggregate maintenance for tasks: keeps parent project stats in sync.
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
}

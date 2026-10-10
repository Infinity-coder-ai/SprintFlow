import '../../core/constants/app_constants.dart';
import '../../database/models/project_invitation_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';

/// Business logic for the employee flow (filtering, sorting, deduping).
/// Presentation lives in the page files; Firebase access lives in services.

List<ProjectModel> filterProjects(
  List<ProjectModel> projects,
  String query,
  String filter,
) {
  final q = query.trim().toLowerCase();
  return projects.where((project) {
    final matchesSearch =
        q.isEmpty ||
        project.title.toLowerCase().contains(q) ||
        project.description.toLowerCase().contains(q);
    final matchesFilter = switch (filter) {
      'Active' => project.status == AppConstants.projectStatusInProgress,
      'Completed' => project.status == AppConstants.projectStatusComplete,
      'On Hold' => project.status == AppConstants.projectStatusDraft,
      _ => true,
    };
    return matchesSearch && matchesFilter;
  }).toList();
}

List<TaskModel> filterTasks(
  List<TaskModel> tasks,
  String query,
  String filter,
) {
  final q = query.trim().toLowerCase();
  return tasks.where((task) {
    final matchesSearch =
        q.isEmpty ||
        task.title.toLowerCase().contains(q) ||
        task.description.toLowerCase().contains(q);
    final matchesFilter = switch (filter) {
      'To Do' => task.status == AppConstants.statusTodo,
      'In Progress' => task.status == AppConstants.statusInProgress,
      'Done' => task.status == AppConstants.statusDone,
      _ => true,
    };
    return matchesSearch && matchesFilter;
  }).toList();
}

/// Pending (non-done) tasks ordered by deadline, dateless tasks last.
List<TaskModel> sortByDeadline(List<TaskModel> tasks) {
  final sorted =
      tasks.where((t) => t.status != AppConstants.statusDone).toList()
        ..sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
  return sorted;
}

DateTime mondayOfWeek([DateTime? now]) {
  final base = now ?? DateTime.now();
  final day = DateTime(base.year, base.month, base.day);
  return day.subtract(Duration(days: base.weekday - 1));
}

List<ProjectInvitationModel> dedupeInvitations(
  List<ProjectInvitationModel> invitations,
) {
  final unique = <String, ProjectInvitationModel>{};
  for (final item in invitations) {
    unique[item.id] = item;
  }
  return unique.values.toList();
}

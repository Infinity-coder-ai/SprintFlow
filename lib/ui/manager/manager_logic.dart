import '../../core/constants/app_constants.dart';
import '../../database/models/project_invitation_model.dart';
import '../../database/models/project_model.dart';
import '../../database/models/task_model.dart';
import '../../database/models/user_model.dart';
import '../../database/models/work_update_model.dart';
import '../../database/services/firebase_service.dart';
import '../../database/services/project_invitation_service.dart';
import '../../database/services/project_service.dart';
import '../../database/services/task_service.dart';

/// Business logic for the manager flow (filtering, stats, team loading).
/// Presentation lives in the page files; Firebase access lives in services.

Future<List<TaskModel>> loadTasksForProjects(
  List<ProjectModel> projects,
) async {
  final result = <TaskModel>[];
  for (final project in projects) {
    result.addAll(await TaskService().getTasksForProjectAsync(project.id));
  }
  return result;
}

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

List<TaskModel> searchTasks(List<TaskModel> tasks, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return tasks;
  return tasks
      .where(
        (task) =>
            task.title.toLowerCase().contains(q) ||
            task.description.toLowerCase().contains(q),
      )
      .toList();
}

List<TaskModel> filterTasks(List<TaskModel> tasks, String filter) {
  switch (filter) {
    case 'To Do':
      return tasks.where((t) => t.status == AppConstants.statusTodo).toList();
    case 'In Progress':
      return tasks
          .where((t) => t.status == AppConstants.statusInProgress)
          .toList();
    case 'Done':
      return tasks.where((t) => t.status == AppConstants.statusDone).toList();
    case 'Review':
      return tasks
          .where((t) => t.status == AppConstants.statusOverdue)
          .toList();
    default:
      return tasks;
  }
}

({int onTrack, int atRisk, int inProgress}) projectHealth(
  List<ProjectModel> projects,
) {
  final onTrack =
      projects
          .where((p) => p.status == AppConstants.projectStatusComplete)
          .length;
  final atRisk =
      projects
          .where(
            (p) =>
                p.status != AppConstants.projectStatusComplete &&
                p.overdueTasks > 0,
          )
          .length;
  return (
    onTrack: onTrack,
    atRisk: atRisk,
    inProgress: projects.length - onTrack - atRisk,
  );
}

({int todo, int inProgress, int done, int overdue}) taskStatusCounts(
  List<TaskModel> tasks,
) {
  return (
    todo: tasks.where((t) => t.status == AppConstants.statusTodo).length,
    inProgress:
        tasks.where((t) => t.status == AppConstants.statusInProgress).length,
    done: tasks.where((t) => t.status == AppConstants.statusDone).length,
    overdue:
        tasks.where((t) => t.status == AppConstants.statusOverdue).length,
  );
}

/// Joined team = project.assignedEmployees PLUS employees with an accepted
/// invitation for this project (covers mirrors that haven't synced yet).
Future<List<UserModel>> loadProjectTeam(String projectId) async {
  final ids = <String>{};
  final project = await ProjectService().getProject(projectId);
  if (project != null) ids.addAll(project.assignedEmployees);
  try {
    final invitations =
        await ProjectInvitationService()
            .streamInvitationsForProject(projectId)
            .first;
    for (final invitation in invitations) {
      if (invitation.isAccepted && invitation.employeeId.isNotEmpty) {
        ids.add(invitation.employeeId);
      }
    }
  } catch (_) {}
  final users = await Future.wait(ids.map(FirebaseService.getUserData));
  final team =
      users
          .whereType<UserModel>()
          .where((user) => user.role == AppConstants.roleEmployee)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return team;
}

DateTime mondayOfWeek([DateTime? now]) {
  final base = now ?? DateTime.now();
  final day = DateTime(base.year, base.month, base.day);
  return day.subtract(Duration(days: base.weekday - 1));
}

List<int> hoursByWeekday(List<WorkUpdateModel> updates, DateTime monday) {
  final hours = List<int>.filled(7, 0);
  for (final update in updates) {
    if (update.createdAt.isBefore(monday)) continue;
    final idx = update.createdAt.weekday - 1;
    if (idx >= 0 && idx < 7) hours[idx] += update.workHours;
  }
  return hours;
}

List<ProjectInvitationModel> dedupeInvitations(
  List<ProjectInvitationModel> invitations,
) {
  final unique = <String, ProjectInvitationModel>{};
  for (final invitation in invitations) {
    unique[invitation.id] = invitation;
  }
  return unique.values.toList();
}

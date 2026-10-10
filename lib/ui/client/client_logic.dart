import '../../core/constants/app_constants.dart';
import '../../database/models/project_model.dart';

/// Business logic for the client flow (filtering, summaries).
/// Presentation lives in the page files; Firebase access lives in services.

List<ProjectModel> visibleProjects(List<ProjectModel> projects) =>
    projects.where((p) => !p.isArchived).toList();

List<ProjectModel> searchProjects(
  List<ProjectModel> projects,
  String query,
) {
  final q = query.trim().toLowerCase();
  final visible = visibleProjects(projects);
  if (q.isEmpty) return visible;
  return visible
      .where(
        (project) =>
            project.title.toLowerCase().contains(q) ||
            project.description.toLowerCase().contains(q),
      )
      .toList();
}

int completedCount(List<ProjectModel> projects) =>
    visibleProjects(
      projects,
    ).where((p) => p.status == AppConstants.projectStatusComplete).length;

double averageProgress(List<ProjectModel> projects) {
  final visible = visibleProjects(projects);
  if (visible.isEmpty) return 0.0;
  return visible.map((p) => p.progressPercentage).reduce((a, b) => a + b) /
      visible.length;
}

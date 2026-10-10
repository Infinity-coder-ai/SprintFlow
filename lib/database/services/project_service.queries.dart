part of 'project_service.dart';

/// Single-source project reads. Same library as [ProjectService], so every
/// existing call site keeps working without new imports.
extension ProjectServiceQueries on ProjectService {
  Stream<List<ProjectModel>> streamProjectsForManager(String managerId) {
    if (managerId.isEmpty) return Stream.value(const <ProjectModel>[]);
    return _mgrProjects
        .where('managerId', isEqualTo: managerId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<ProjectModel>> streamProjectsForEmployee(String employeeId) {
    if (employeeId.isEmpty) return Stream.value(const <ProjectModel>[]);
    return _mgrProjects
        .where('assignedEmployees', arrayContains: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ProjectModel.fromFirestore(d)).toList(),
        );
  }

  Stream<ProjectModel?> streamProject(String projectId) {
    return _mgrProjects.doc(projectId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProjectModel.fromFirestore(doc);
    });
  }

  Stream<ProjectModel?> streamClientProject(String projectId) {
    return _clientProjects.doc(projectId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProjectModel.fromFirestore(doc);
    });
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _mgrProjects.doc(projectId).get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }
}

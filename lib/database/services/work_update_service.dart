import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/work_update_model.dart';
import 'project_service.dart';
import 'task_service.dart';

class WorkUpdateService {
  final FirebaseFirestore _db;
  WorkUpdateService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workUpdates =>
      _db.collection(AppConstants.collectionWorkUpdates);

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForEmployee(
    String employeeId,
  ) {
    return _workUpdates
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList(),
        );
  }

  Future<String> createWorkUpdate({
    required String taskId,
    required String employeeId,
    required String projectId,
    required String update,
    required int workHours,
    required int progressPercentage,
  }) async {
    final doc = _workUpdates.doc();
    final now = DateTime.now();
    final project = await ProjectService().getProject(projectId);
    final model = WorkUpdateModel(
      id: doc.id,
      taskId: taskId,
      employeeId: employeeId,
      projectId: projectId,
      clientId: project?.clientId,
      clientEmail: project?.clientEmail,
      update: update,
      workHours: workHours,
      progressPercentage: progressPercentage,
      createdAt: now,
    );

    // Store the work update
    await doc.set(model.toFirestore());

    // Update the actual task progress and hours in both manager and employee collections
    final taskService = TaskService();
    await taskService.updateTaskProgress(taskId, progressPercentage, workHours);

    return doc.id;
  }

  Stream<Map<String, int>> streamWeeklyWorkHours(String employeeId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _workUpdates
        .where('employeeId', isEqualTo: employeeId)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(weekEnd))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
          final Map<String, int> daily = {};
          for (final d in snap.docs) {
            final update = WorkUpdateModel.fromFirestore(d);
            final key = update.createdAt.day.toString();
            daily[key] = (daily[key] ?? 0) + update.workHours;
          }
          return daily;
        });
  }

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForProjectsSince(
    List<String> projectIds,
    DateTime since,
  ) {
    if (projectIds.isEmpty) return Stream.value(const <WorkUpdateModel>[]);
    final ids = projectIds.length > 10 ? projectIds.sublist(0, 10) : projectIds;
    return _workUpdates
        .where('projectId', whereIn: ids)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForTaskByEmployee(
    String taskId,
    String employeeId,
  ) {
    if (taskId.isEmpty || employeeId.isEmpty)
      return Stream.value(const <WorkUpdateModel>[]);
    return _workUpdates
        .where('taskId', isEqualTo: taskId)
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }
}

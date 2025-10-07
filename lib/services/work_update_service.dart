import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_update_model.dart';
import 'task_service.dart';

class WorkUpdateService {
  final FirebaseFirestore _db;
  WorkUpdateService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workUpdates => _db.collection('work_updates');

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForEmployee(String employeeId) {
    return _workUpdates
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList());
  }

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForProject(String projectId) {
    return _workUpdates
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList());
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
    final model = WorkUpdateModel(
      id: doc.id,
      taskId: taskId,
      employeeId: employeeId,
      projectId: projectId,
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

  Future<List<WorkUpdateModel>> getWeeklyWorkUpdates(String employeeId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final querySnapshot = await _workUpdates
        .where('employeeId', isEqualTo: employeeId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .where('createdAt', isLessThan: Timestamp.fromDate(weekEnd))
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs.map((doc) => WorkUpdateModel.fromFirestore(doc)).toList();
  }

  Future<Map<String, int>> getWeeklyWorkHours(String employeeId) async {
    final updates = await getWeeklyWorkUpdates(employeeId);
    final Map<String, int> dailyHours = {};
    
    for (final update in updates) {
      final day = update.createdAt.toLocal().day.toString();
      dailyHours[day] = (dailyHours[day] ?? 0) + update.workHours;
    }
    
    return dailyHours;
  }

  Stream<Map<String, int>> streamWeeklyWorkHours(String employeeId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _workUpdates
        .where('employeeId', isEqualTo: employeeId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
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

  Future<void> deleteWorkUpdatesForProject(String projectId) async {
    final querySnapshot = await _workUpdates
        .where('projectId', isEqualTo: projectId)
        .get();
    
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<WorkUpdateModel>> getWorkUpdatesForTask(String taskId) async {
    final querySnapshot = await _workUpdates
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs.map((doc) => WorkUpdateModel.fromFirestore(doc)).toList();
  }

  Stream<List<WorkUpdateModel>> streamWorkUpdatesForTask(String taskId) {
    return _workUpdates
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => WorkUpdateModel.fromFirestore(d)).toList());
  }

  Future<void> deleteWorkUpdatesForTask(String taskId) async {
    final querySnapshot = await _workUpdates
        .where('taskId', isEqualTo: taskId)
        .get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}

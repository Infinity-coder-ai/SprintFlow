import 'package:cloud_firestore/cloud_firestore.dart';

class WorkUpdateModel {
  final String id;
  final String taskId;
  final String employeeId;
  final String projectId;
  final String update;
  final int workHours;
  final int progressPercentage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkUpdateModel({
    required this.id,
    required this.taskId,
    required this.employeeId,
    required this.projectId,
    required this.update,
    required this.workHours,
    required this.progressPercentage,
    required this.createdAt,
    this.updatedAt,
  });

  factory WorkUpdateModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WorkUpdateModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      employeeId: data['employeeId'] ?? '',
      projectId: data['projectId'] ?? '',
      update: data['update'] ?? '',
      workHours: data['workHours'] ?? 0,
      progressPercentage: data['progressPercentage'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'employeeId': employeeId,
      'projectId': projectId,
      'update': update,
      'workHours': workHours,
      'progressPercentage': progressPercentage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  WorkUpdateModel copyWith({
    String? id,
    String? taskId,
    String? employeeId,
    String? projectId,
    String? update,
    int? workHours,
    int? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkUpdateModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      employeeId: employeeId ?? this.employeeId,
      projectId: projectId ?? this.projectId,
      update: update ?? this.update,
      workHours: workHours ?? this.workHours,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

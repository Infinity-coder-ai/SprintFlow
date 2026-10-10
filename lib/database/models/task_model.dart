import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import 'subtask_model.dart';

part 'task_model.extensions.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status; // todo, in_progress, done, overdue
  final String priority; // low, medium, high, critical
  final String projectId; // Which project this task belongs to
  final String? assignedTo; // Employee ID assigned to this task
  final String createdBy; // Manager ID who created this task

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deadline;
  final DateTime? completedAt;
  final DateTime? startedAt;

  // Task details
  final List<SubTask> subtasks;
  final List<String> attachments; // File URLs
  final List<String> tags;
  final String? sprintId; // Optional sprint assignment
  final String? milestoneId; // Optional milestone assignment

  // Progress tracking
  final double progressPercentage; // 0.0 to 100.0
  final int estimatedHours;
  final int actualHours;

  // Comments and communication
  final List<String> commentIds; // References to comments
  final bool hasUnreadComments;

  // Task dependencies
  final List<String> dependencies; // Task IDs this task depends on
  final List<String> dependents; // Task IDs that depend on this task

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.deadline,
    this.completedAt,
    this.startedAt,
    this.subtasks = const [],
    this.attachments = const [],
    this.tags = const [],
    this.sprintId,
    this.milestoneId,
    this.progressPercentage = 0.0,
    this.estimatedHours = 0,
    this.actualHours = 0,
    this.commentIds = const [],
    this.hasUnreadComments = false,
    this.dependencies = const [],
    this.dependents = const [],
  });

  // Factory constructor from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? AppConstants.statusTodo,
      priority: data['priority'] ?? AppConstants.priorityMedium,
      projectId: data['projectId'] ?? '',
      assignedTo: data['assignedTo'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      deadline:
          data['deadline'] != null
              ? (data['deadline'] as Timestamp).toDate()
              : null,
      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
      startedAt:
          data['startedAt'] != null
              ? (data['startedAt'] as Timestamp).toDate()
              : null,
      subtasks:
          (data['subtasks'] as List<dynamic>? ?? [])
              .map((subtask) => SubTask.fromMap(subtask))
              .toList(),
      attachments: List<String>.from(data['attachments'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      sprintId: data['sprintId'],
      milestoneId: data['milestoneId'],
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      estimatedHours: data['estimatedHours'] ?? 0,
      actualHours: data['actualHours'] ?? 0,
      commentIds: List<String>.from(data['commentIds'] ?? []),
      hasUnreadComments: data['hasUnreadComments'] ?? false,
      dependencies: List<String>.from(data['dependencies'] ?? []),
      dependents: List<String>.from(data['dependents'] ?? []),
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: $status, progress: $progressPercentage%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

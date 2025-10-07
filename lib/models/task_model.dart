import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

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
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      deadline: data['deadline'] != null 
          ? (data['deadline'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      startedAt: data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null,
      subtasks: (data['subtasks'] as List<dynamic>? ?? [])
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

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'projectId': projectId,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'attachments': attachments,
      'tags': tags,
      'sprintId': sprintId,
      'milestoneId': milestoneId,
      'progressPercentage': progressPercentage,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'commentIds': commentIds,
      'hasUnreadComments': hasUnreadComments,
      'dependencies': dependencies,
      'dependents': dependents,
    };
  }

  // Copy with method
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? projectId,
    String? assignedTo,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadline,
    DateTime? completedAt,
    DateTime? startedAt,
    List<SubTask>? subtasks,
    List<String>? attachments,
    List<String>? tags,
    String? sprintId,
    String? milestoneId,
    double? progressPercentage,
    int? estimatedHours,
    int? actualHours,
    List<String>? commentIds,
    bool? hasUnreadComments,
    List<String>? dependencies,
    List<String>? dependents,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deadline: deadline ?? this.deadline,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      sprintId: sprintId ?? this.sprintId,
      milestoneId: milestoneId ?? this.milestoneId,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      commentIds: commentIds ?? this.commentIds,
      hasUnreadComments: hasUnreadComments ?? this.hasUnreadComments,
      dependencies: dependencies ?? this.dependencies,
      dependents: dependents ?? this.dependents,
    );
  }

  // Helper methods
  bool get isTodo => status == AppConstants.statusTodo;
  bool get isInProgress => status == AppConstants.statusInProgress;
  bool get isDone => status == AppConstants.statusDone;
  bool get isOverdue => status == AppConstants.statusOverdue;

  bool get isLowPriority => priority == AppConstants.priorityLow;
  bool get isMediumPriority => priority == AppConstants.priorityMedium;
  bool get isHighPriority => priority == AppConstants.priorityHigh;
  bool get isCriticalPriority => priority == AppConstants.priorityCritical;

  // Check if task is overdue
  bool get isOverdueTask {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isDone;
  }

  // Get remaining days
  int get remainingDays {
    if (deadline == null) return 0;
    return deadline!.difference(DateTime.now()).inDays;
  }

  // Get completed subtasks count
  int get completedSubtasksCount {
    return subtasks.where((subtask) => subtask.isCompleted).length;
  }

  // Get total subtasks count
  int get totalSubtasksCount {
    return subtasks.length;
  }

  // Calculate progress based on subtasks
  double get calculatedProgress {
    if (subtasks.isEmpty) return progressPercentage;
    if (totalSubtasksCount == 0) return 0.0;
    return (completedSubtasksCount / totalSubtasksCount) * 100.0;
  }

  // Check if task can be moved to next status
  bool canMoveToNextStatus() {
    if (isDone) return false;
    if (isTodo) return true;
    if (isInProgress) return true;
    return false;
  }

  // Get next status
  String get nextStatus {
    if (isTodo) return AppConstants.statusInProgress;
    if (isInProgress) return AppConstants.statusDone;
    return status;
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

// SubTask class for task breakdown
class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completedAt;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'SubTask(id: $id, title: $title, completed: $isCompleted)';
  }
}

part of 'task_model.dart';

/// Serialization, copying, and derived state for [TaskModel].
/// Same library as the model, so every call site keeps working unchanged.
extension TaskModelSerialization on TaskModel {
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
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
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
}

extension TaskModelHelpers on TaskModel {
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
}

part of 'task_model.dart';

/// Serialization and copying for [TaskModel].
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

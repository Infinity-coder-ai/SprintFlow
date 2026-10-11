part of 'project_model.dart';

/// Serialization and copying for [ProjectModel].
/// Same library as the model, so every call site keeps working unchanged.
extension ProjectModelSerialization on ProjectModel {
  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'managerId': managerId,
      'clientId': clientId,
      'clientEmail': clientEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'expectedFinish':
          expectedFinish != null ? Timestamp.fromDate(expectedFinish!) : null,
      'actualFinish':
          actualFinish != null ? Timestamp.fromDate(actualFinish!) : null,
      'assignedEmployees': assignedEmployees,
      'sprints': sprints,
      'milestones': milestones,
      'progressPercentage': progressPercentage,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
      'isPublic': isPublic,
      'isArchived': isArchived,
      'projectLogo': projectLogo,
      'projectColor': projectColor,
      'shareProgressWithClient': shareProgressWithClient,
      'shareMilestonesWithClient': shareMilestonesWithClient,
      'shareFilesWithClient': shareFilesWithClient,
      'analytics': analytics,
      'tags': tags,
    };
  }

  // Copy with method
  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? managerId,
    String? clientId,
    String? clientEmail,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? updatedAt,
    DateTime? expectedFinish,
    DateTime? actualFinish,
    List<String>? assignedEmployees,
    List<String>? sprints,
    List<String>? milestones,
    double? progressPercentage,
    int? totalTasks,
    int? completedTasks,
    int? overdueTasks,
    bool? isPublic,
    bool? isArchived,
    String? projectLogo,
    String? projectColor,
    bool? shareProgressWithClient,
    bool? shareMilestonesWithClient,
    bool? shareFilesWithClient,
    Map<String, dynamic>? analytics,
    List<String>? tags,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      clientId: clientId ?? this.clientId,
      clientEmail: clientEmail ?? this.clientEmail,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      updatedAt: updatedAt ?? this.updatedAt,
      expectedFinish: expectedFinish ?? this.expectedFinish,
      actualFinish: actualFinish ?? this.actualFinish,
      assignedEmployees: assignedEmployees ?? this.assignedEmployees,
      sprints: sprints ?? this.sprints,
      milestones: milestones ?? this.milestones,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      isPublic: isPublic ?? this.isPublic,
      isArchived: isArchived ?? this.isArchived,
      projectLogo: projectLogo ?? this.projectLogo,
      projectColor: projectColor ?? this.projectColor,
      shareProgressWithClient:
          shareProgressWithClient ?? this.shareProgressWithClient,
      shareMilestonesWithClient:
          shareMilestonesWithClient ?? this.shareMilestonesWithClient,
      shareFilesWithClient: shareFilesWithClient ?? this.shareFilesWithClient,
      analytics: analytics ?? this.analytics,
      tags: tags ?? this.tags,
    );
  }
}

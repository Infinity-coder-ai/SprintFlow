import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

part 'project_model.extensions.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String status; // draft, in_progress, complete, archived
  final String managerId; // Who manages this project
  final String clientId; // Which client this project is for
  final String? clientEmail;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? updatedAt;
  final DateTime? expectedFinish;
  final DateTime? actualFinish;

  // Team and assignments
  final List<String> assignedEmployees; // Employee IDs assigned to this project
  final List<String> sprints; // Sprint IDs associated with this project
  final List<String> milestones; // Milestone IDs

  // Progress tracking
  final double progressPercentage; // 0.0 to 100.0
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;

  // Project settings
  final bool isPublic; // Whether client can view this project
  final bool isArchived;
  final String? projectLogo;
  final String? projectColor; // Hex color for project branding

  // Client visibility settings
  final bool shareProgressWithClient;
  final bool shareMilestonesWithClient;
  final bool shareFilesWithClient;

  // Analytics and reporting
  final Map<String, dynamic>? analytics; // Stored analytics data
  final List<String> tags; // Project tags for categorization

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.managerId,
    required this.clientId,
    this.clientEmail,
    required this.createdAt,
    this.startDate,
    this.updatedAt,
    this.expectedFinish,
    this.actualFinish,
    this.assignedEmployees = const [],
    this.sprints = const [],
    this.milestones = const [],
    this.progressPercentage = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.overdueTasks = 0,
    this.isPublic = true,
    this.isArchived = false,
    this.projectLogo,
    this.projectColor,
    this.shareProgressWithClient = true,
    this.shareMilestonesWithClient = true,
    this.shareFilesWithClient = false,
    this.analytics,
    this.tags = const [],
  });

  // Factory constructor from Firestore document
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? AppConstants.projectStatusDraft,
      managerId: data['managerId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientEmail: data['clientEmail'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate:
          data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : ((data['createdAt'] as Timestamp?)?.toDate()),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      expectedFinish:
          data['expectedFinish'] != null
              ? (data['expectedFinish'] as Timestamp).toDate()
              : null,
      actualFinish:
          data['actualFinish'] != null
              ? (data['actualFinish'] as Timestamp).toDate()
              : null,
      assignedEmployees: List<String>.from(data['assignedEmployees'] ?? []),
      sprints: List<String>.from(data['sprints'] ?? []),
      milestones: List<String>.from(data['milestones'] ?? []),
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      totalTasks: data['totalTasks'] ?? 0,
      completedTasks: data['completedTasks'] ?? 0,
      overdueTasks: data['overdueTasks'] ?? 0,
      isPublic: data['isPublic'] ?? true,
      isArchived: data['isArchived'] ?? false,
      projectLogo: data['projectLogo'],
      projectColor: data['projectColor'],
      shareProgressWithClient: data['shareProgressWithClient'] ?? true,
      shareMilestonesWithClient: data['shareMilestonesWithClient'] ?? true,
      shareFilesWithClient: data['shareFilesWithClient'] ?? false,
      analytics: data['analytics'],
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title, status: $status, progress: $progressPercentage%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

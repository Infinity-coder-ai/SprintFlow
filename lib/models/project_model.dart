import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String status; // draft, in_progress, complete, archived
  final String managerId; // Who manages this project
  final String clientId; // Which client this project is for
  final DateTime createdAt;
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
    required this.createdAt,
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      expectedFinish: data['expectedFinish'] != null 
          ? (data['expectedFinish'] as Timestamp).toDate() 
          : null,
      actualFinish: data['actualFinish'] != null 
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

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'managerId': managerId,
      'clientId': clientId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'expectedFinish': expectedFinish != null ? Timestamp.fromDate(expectedFinish!) : null,
      'actualFinish': actualFinish != null ? Timestamp.fromDate(actualFinish!) : null,
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
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
      shareProgressWithClient: shareProgressWithClient ?? this.shareProgressWithClient,
      shareMilestonesWithClient: shareMilestonesWithClient ?? this.shareMilestonesWithClient,
      shareFilesWithClient: shareFilesWithClient ?? this.shareFilesWithClient,
      analytics: analytics ?? this.analytics,
      tags: tags ?? this.tags,
    );
  }

  // Helper methods
  bool get isDraft => status == AppConstants.projectStatusDraft;
  bool get isInProgress => status == AppConstants.projectStatusInProgress;
  bool get isComplete => status == AppConstants.projectStatusComplete;
  bool get isArchivedStatus => status == AppConstants.projectStatusArchived;

  // Deadline status calculation
  String get deadlineStatus {
    if (expectedFinish == null) return AppConstants.deadlineOnTime;
    
    final now = DateTime.now();
    final daysUntilDeadline = expectedFinish!.difference(now).inDays;
    
    if (daysUntilDeadline < 0) {
      return AppConstants.deadlineLate;
    } else if (daysUntilDeadline <= 3) {
      return AppConstants.deadlineOnTime;
    } else {
      return AppConstants.deadlineEarly;
    }
  }

  // Check if project is overdue
  bool get isOverdue {
    if (expectedFinish == null) return false;
    return DateTime.now().isAfter(expectedFinish!);
  }

  // Get remaining days
  int get remainingDays {
    if (expectedFinish == null) return 0;
    return expectedFinish!.difference(DateTime.now()).inDays;
  }

  // Check if project can be viewed by client
  bool canBeViewedByClient() {
    return isPublic && !isArchived;
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

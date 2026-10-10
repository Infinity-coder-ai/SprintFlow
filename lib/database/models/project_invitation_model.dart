import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class ProjectInvitationModel {
  final String id;
  final String projectId;
  final String projectTitle;
  final String managerId;
  final String managerName;
  final String employeeId;
  final String employeeEmail;
  final String employeeName;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const ProjectInvitationModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.managerId,
    required this.managerName,
    required this.employeeId,
    required this.employeeEmail,
    required this.employeeName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory ProjectInvitationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return ProjectInvitationModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      projectTitle: data['projectTitle'] ?? '',
      managerId: data['managerId'] ?? '',
      managerName: data['managerName'] ?? '',
      employeeId: data['employeeId'] ?? '',
      employeeEmail: data['employeeEmail'] ?? '',
      employeeName: data['employeeName'] ?? '',
      status: data['status'] ?? AppConstants.projectInvitationStatusPending,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'projectTitle': projectTitle,
      'managerId': managerId,
      'managerName': managerName,
      'employeeId': employeeId,
      'employeeEmail': employeeEmail,
      'employeeName': employeeName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  ProjectInvitationModel copyWith({
    String? id,
    String? projectId,
    String? projectTitle,
    String? managerId,
    String? managerName,
    String? employeeId,
    String? employeeEmail,
    String? employeeName,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return ProjectInvitationModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      employeeId: employeeId ?? this.employeeId,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  bool get isPending => status == AppConstants.projectInvitationStatusPending;
  bool get isAccepted => status == AppConstants.projectInvitationStatusAccepted;
  bool get isRejected => status == AppConstants.projectInvitationStatusRejected;
}

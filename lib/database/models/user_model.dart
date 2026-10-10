import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

part 'user_model.extensions.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // manager, employee, client
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final bool isOnline;

  // Role-specific fields
  final String? managerId; // For employees - who created their account
  final List<String>
  assignedProjects; // For employees - projects they're assigned to
  final List<String> managedProjects; // For managers - projects they manage
  final List<String> clientProjects; // For clients - projects they can view
  final List<String>
  activeClients; // For clients - array of client IDs they can access

  // Employee-specific fields
  final String? department;
  final String? position;
  final DateTime? hireDate;
  final double? performanceRating;

  // Manager-specific fields
  final List<String> managedEmployees; // List of employee IDs they manage
  final List<String> managedClients; // List of client IDs they manage

  // Client-specific fields
  final String? companyName;
  final String? companyLogo;
  final String? contactPerson;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.phone,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.isOnline = false,
    this.managerId,
    this.assignedProjects = const [],
    this.managedProjects = const [],
    this.clientProjects = const [],
    this.activeClients = const [],
    this.department,
    this.position,
    this.hireDate,
    this.performanceRating,
    this.managedEmployees = const [],
    this.managedClients = const [],
    this.companyName,
    this.companyLogo,
    this.contactPerson,
  });

  // Factory constructor from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? AppConstants.roleEmployee,
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      phone: data['phone'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt:
          data['lastLoginAt'] != null
              ? (data['lastLoginAt'] as Timestamp).toDate()
              : null,
      isActive: data['isActive'] ?? true,
      isOnline: data['isOnline'] ?? false,
      managerId: data['managerId'],
      assignedProjects: List<String>.from(data['assignedProjects'] ?? []),
      managedProjects: List<String>.from(data['managedProjects'] ?? []),
      clientProjects: List<String>.from(data['clientProjects'] ?? []),
      activeClients: List<String>.from(data['activeClients'] ?? []),
      department: data['department'],
      position: data['position'],
      hireDate:
          data['hireDate'] != null
              ? (data['hireDate'] as Timestamp).toDate()
              : null,
      performanceRating: data['performanceRating']?.toDouble(),
      managedEmployees: List<String>.from(data['managedEmployees'] ?? []),
      managedClients: List<String>.from(data['managedClients'] ?? []),
      companyName: data['companyName'],
      companyLogo: data['companyLogo'],
      contactPerson: data['contactPerson'],
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, role: $role, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

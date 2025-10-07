import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

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
  final List<String> assignedProjects; // For employees - projects they're assigned to
  final List<String> managedProjects; // For managers - projects they manage
  final List<String> clientProjects; // For clients - projects they can view
  final List<String> activeClients; // For clients - array of client IDs they can access
  
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
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
      hireDate: data['hireDate'] != null 
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

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
      'isOnline': isOnline,
      'managerId': managerId,
      'assignedProjects': assignedProjects,
      'managedProjects': managedProjects,
      'clientProjects': clientProjects,
      'activeClients': activeClients,
      'department': department,
      'position': position,
      'hireDate': hireDate != null ? Timestamp.fromDate(hireDate!) : null,
      'performanceRating': performanceRating,
      'managedEmployees': managedEmployees,
      'managedClients': managedClients,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'contactPerson': contactPerson,
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? avatarUrl,
    String? bio,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isOnline,
    String? managerId,
    List<String>? assignedProjects,
    List<String>? managedProjects,
    List<String>? clientProjects,
    List<String>? activeClients,
    String? department,
    String? position,
    DateTime? hireDate,
    double? performanceRating,
    List<String>? managedEmployees,
    List<String>? managedClients,
    String? companyName,
    String? companyLogo,
    String? contactPerson,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      managerId: managerId ?? this.managerId,
      assignedProjects: assignedProjects ?? this.assignedProjects,
      managedProjects: managedProjects ?? this.managedProjects,
      clientProjects: clientProjects ?? this.clientProjects,
      activeClients: activeClients ?? this.activeClients,
      department: department ?? this.department,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      performanceRating: performanceRating ?? this.performanceRating,
      managedEmployees: managedEmployees ?? this.managedEmployees,
      managedClients: managedClients ?? this.managedClients,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      contactPerson: contactPerson ?? this.contactPerson,
    );
  }

  // Helper methods for role checking
  bool get isManager => role == AppConstants.roleManager;
  bool get isEmployee => role == AppConstants.roleEmployee;
  bool get isClient => role == AppConstants.roleClient;

  // Helper methods for permissions
  bool canManageProject(String projectId) {
    if (isManager) {
      return managedProjects.contains(projectId);
    }
    return false;
  }

  bool canViewProject(String projectId) {
    if (isManager) {
      return managedProjects.contains(projectId);
    } else if (isEmployee) {
      return assignedProjects.contains(projectId);
    } else if (isClient) {
      return clientProjects.contains(projectId);
    }
    return false;
  }

  bool canManageUser(String userId) {
    if (isManager) {
      return managedEmployees.contains(userId) || managedClients.contains(userId);
    }
    return false;
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

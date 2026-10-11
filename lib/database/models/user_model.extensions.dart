part of 'user_model.dart';

/// Serialization, copying, and role checks for [UserModel].
/// Same library as the model, so every call site keeps working unchanged.
extension UserModelSerialization on UserModel {
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
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
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
}

extension UserModelHelpers on UserModel {
  // Helper methods for role checking
  bool get isManager => role == AppConstants.roleManager;
  bool get isEmployee => role == AppConstants.roleEmployee;
  bool get isClient => role == AppConstants.roleClient;
}

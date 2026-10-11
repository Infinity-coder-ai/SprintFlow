import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/project_invitation_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'task_service.dart';
import 'work_update_service.dart';
import 'manager_update_service.dart';

part 'project_service.queries.dart';
part 'project_service.merged.dart';

class ProjectService {
  final FirebaseFirestore _db;
  ProjectService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _mgrProjects =>
      _db.collection(AppConstants.collectionManagersProjects);
  CollectionReference<Map<String, dynamic>> get _clientProjects =>
      _db.collection(AppConstants.collectionClientsProjects);

  Future<String> createProject({
    required String title,
    required String description,
    required String managerId,
    String? clientId,
    String? clientEmail,
    DateTime? startDate,
    DateTime? expectedFinish,
    List<String> assignedEmployees = const [],
  }) async {
    final resolved = await _resolveClient(
      clientId: clientId,
      clientEmail: clientEmail,
    );
    final resolvedClientId = resolved.$1;
    final resolvedClientEmail = resolved.$2;

    final doc = _mgrProjects.doc();
    final now = DateTime.now();
    final model = ProjectModel(
      id: doc.id,
      title: title,
      description: description,
      status: AppConstants.projectStatusDraft,
      managerId: managerId,
      clientId: resolvedClientId ?? '',
      clientEmail: resolvedClientEmail,
      createdAt: now,
      startDate: startDate ?? now,
      expectedFinish: expectedFinish,
      assignedEmployees: assignedEmployees,
      isPublic: true,
      isArchived: false,
      progressPercentage: 0,
      totalTasks: 0,
      completedTasks: 0,
      overdueTasks: 0,
    );

    final clientKeys = <String>[];
    if (resolvedClientId != null && resolvedClientId.isNotEmpty) {
      clientKeys.add(resolvedClientId);
    }
    if (resolvedClientEmail != null && resolvedClientEmail.isNotEmpty) {
      clientKeys.add(resolvedClientEmail);
    }

    final mgrData = {...model.toFirestore(), 'clientKeys': clientKeys};
    await doc.set(mgrData);

    await _clientProjects.doc(doc.id).set({
      'id': doc.id,
      'title': title,
      'description': description,
      'clientId': resolvedClientId,
      'clientEmail': resolvedClientEmail,
      'clientKeys': clientKeys,
      'managerId': managerId,
      'assignedEmployees': assignedEmployees,
      'createdAt': Timestamp.fromDate(now),
      'startDate': Timestamp.fromDate(startDate ?? now),
      'expectedFinish':
          expectedFinish != null ? Timestamp.fromDate(expectedFinish) : null,
      'progressPercentage': 0,
      'totalTasks': 0,
      'completedTasks': 0,
      'overdueTasks': 0,
      'status': AppConstants.projectStatusDraft,
    });

    if (resolvedClientId != null && resolvedClientId.isNotEmpty) {
      await FirebaseService.updateUserDocument(resolvedClientId, {
        'clientProjects': FieldValue.arrayUnion([doc.id]),
      });
    }

    await FirebaseService.updateUserDocument(managerId, {
      'managedProjects': FieldValue.arrayUnion([doc.id]),
    });

    return doc.id;
  }

  Future<(String?, String?)> _resolveClient({
    String? clientId,
    String? clientEmail,
  }) async {
    String? id = (clientId ?? '').trim();
    final rawEmail = (clientEmail ?? '').trim().toLowerCase();
    String? email = rawEmail.isEmpty ? null : rawEmail;
    if (id.isEmpty) id = null;

    UserModel? user;
    if (id != null) {
      user = await FirebaseService.getUserData(id);
    } else if (email != null) {
      user = await FirebaseService.getUserByEmail(email);
    }

    if (user != null && user.isClient) {
      return (user.id, user.email.toLowerCase());
    }

    return (id, email);
  }

  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _mgrProjects.doc(projectId).update(data);

    const mirrorKeys = {
      'title',
      'description',
      'expectedFinish',
      'startDate',
      'progressPercentage',
      'totalTasks',
      'completedTasks',
      'overdueTasks',
      'status',
      'assignedEmployees',
      'clientId',
      'clientEmail',
      'clientKeys',
      'updatedAt',
    };
    final mirror = <String, dynamic>{};
    for (final key in mirrorKeys) {
      if (data.containsKey(key)) mirror[key] = data[key];
    }
    if (mirror.isNotEmpty) {
      try {
        await _clientProjects.doc(projectId).update(mirror);
      } catch (_) {
        // Client mirror may not exist for legacy documents.
      }
    }
  }

}

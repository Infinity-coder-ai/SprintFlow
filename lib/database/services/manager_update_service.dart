import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/manager_update_model.dart';
import 'project_invitation_service.dart';

class ManagerUpdateService {
  final FirebaseFirestore _db;
  ManagerUpdateService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _updates =>
      _db.collection(AppConstants.collectionManagerUpdates);

  Future<void> createUpdate({
    required String projectId,
    required String clientId,
    required String managerId,
    required String title,
    required String message,
    String? clientEmail,
  }) async {
    final doc = _updates.doc();
    final update = ManagerUpdateModel(
      id: doc.id,
      projectId: projectId,
      clientId: clientId,
      clientEmail: clientEmail,
      managerId: managerId,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    await doc.set(update.toMap());

    final notifyUserId = clientId;
    if (notifyUserId.isNotEmpty) {
      await ProjectInvitationService().createNotification(
        userId: notifyUserId,
        type: AppConstants.notificationProjectUpdate,
        title: title,
        message: message,
        extra: {'projectId': projectId},
      );
    }
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForClient(
    String clientId, {
    String? clientEmail,
  }) {
    final streams = <Stream<List<ManagerUpdateModel>>>[];
    if (clientId.isNotEmpty) {
      streams.add(
        _updates
            .where('clientId', isEqualTo: clientId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map(ManagerUpdateModel.fromDoc).toList()),
      );
    }
    final email = (clientEmail ?? '').trim().toLowerCase();
    if (email.isNotEmpty) {
      streams.add(
        _updates
            .where('clientEmail', isEqualTo: email)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map(ManagerUpdateModel.fromDoc).toList()),
      );
    }
    if (streams.isEmpty) return Stream.value(const <ManagerUpdateModel>[]);
    if (streams.length == 1) return streams.first;

    return Stream.multi((controller) {
      final sourceData = <String, List<ManagerUpdateModel>>{};
      final subscriptions = <StreamSubscription<List<ManagerUpdateModel>>>[];

      void rebuild() {
        final merged = <String, ManagerUpdateModel>{};
        for (final items in sourceData.values) {
          for (final item in items) {
            merged[item.id] = item;
          }
        }
        final all =
            merged.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (!controller.isClosed) controller.add(all);
      }

      for (var i = 0; i < streams.length; i++) {
        subscriptions.add(
          streams[i].listen(
            (items) {
              sourceData['$i'] = items;
              rebuild();
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!controller.isClosed) controller.addError(error, stackTrace);
            },
          ),
        );
      }

      controller.onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForProject(String projectId) {
    if (projectId.isEmpty) return Stream.value(const <ManagerUpdateModel>[]);
    return _updates
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ManagerUpdateModel.fromDoc).toList());
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForProjects(
    List<String> projectIds,
  ) {
    if (projectIds.isEmpty) {
      return Stream.value(const <ManagerUpdateModel>[]);
    }
    final ids = projectIds.length > 10 ? projectIds.sublist(0, 10) : projectIds;
    return _updates.where('projectId', whereIn: ids).snapshots().map((snap) {
      final list = snap.docs.map(ManagerUpdateModel.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> deleteUpdatesForProject(String projectId) async {
    final batch = _db.batch();
    final q = await _updates.where('projectId', isEqualTo: projectId).get();
    for (final d in q.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

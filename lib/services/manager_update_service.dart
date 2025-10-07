import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manager_update_model.dart';

class ManagerUpdateService {
  static final _db = FirebaseFirestore.instance;
  static const String collection = 'manager_updates';

  Future<void> createUpdate({
    required String projectId,
    required String clientId,
    required String managerId,
    required String title,
    required String message,
  }) async {
    final doc = _db.collection(collection).doc();
    final update = ManagerUpdateModel(
      id: doc.id,
      projectId: projectId,
      clientId: clientId,
      managerId: managerId,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    await doc.set(update.toMap());
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForClient(String clientId) {
    return _db
        .collection(collection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ManagerUpdateModel.fromDoc).toList());
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForProject(String projectId) {
    return _db
        .collection(collection)
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ManagerUpdateModel.fromDoc).toList());
  }

  Stream<List<ManagerUpdateModel>> streamUpdatesForProjects(List<String> projectIds) {
    if (projectIds.isEmpty) {
      return Stream.value(const <ManagerUpdateModel>[]);
    }
    // Firestore whereIn supports up to 10 elements; if more, take first 10 for now
    final ids = projectIds.length > 10 ? projectIds.sublist(0, 10) : projectIds;
    return _db
        .collection(collection)
        .where('projectId', whereIn: ids)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(ManagerUpdateModel.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> deleteUpdatesForProject(String projectId) async {
    final batch = _db.batch();
    final q = await _db.collection(collection).where('projectId', isEqualTo: projectId).get();
    for (final d in q.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}



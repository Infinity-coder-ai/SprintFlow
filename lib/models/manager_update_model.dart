import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerUpdateModel {
  final String id;
  final String projectId;
  final String clientId;
  final String managerId;
  final String title;
  final String message;
  final DateTime createdAt;

  ManagerUpdateModel({
    required this.id,
    required this.projectId,
    required this.clientId,
    required this.managerId,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'clientId': clientId,
      'managerId': managerId,
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ManagerUpdateModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    return ManagerUpdateModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      clientId: data['clientId'] ?? '',
      managerId: data['managerId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}



import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool isUrgent;
  final String? targetProfileId;
  final String targetProfileName;
  final DateTime? updatedAt;

  NoteModel({
    this.id = '',
    required this.title,
    required this.content,
    this.isUrgent = false,
    this.targetProfileId,
    this.targetProfileName = "Général",
    this.updatedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      isUrgent: data['isUrgent'] ?? false,
      targetProfileId: data['targetProfileId'],
      targetProfileName: data['targetProfileName'] ?? 'Général',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'isUrgent': isUrgent,
      'targetProfileId': targetProfileId,
      'targetProfileName': targetProfileName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

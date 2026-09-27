import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistoryModel {
  final String id;
  final String productName;
  final int nbUnites;
  final String productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScanHistoryModel({
    this.id = '',
    required this.productName,
    required this.nbUnites,
    required this.productId,
    this.createdAt,
    this.updatedAt,
  });

  factory ScanHistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ScanHistoryModel(
      id: doc.id,
      productName: data['productName'] ?? '',
      nbUnites: data['nbUnites'] ?? 0,
      productId: data['productId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

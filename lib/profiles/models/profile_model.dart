import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String name;
  final String relation;
  final int age;
  final List<String> allergies;
  final String photoUrl;
  final DateTime? lastUpdated;

  ProfileModel({
    this.id = '',
    required this.name,
    required this.relation,
    required this.age,
    required this.allergies,
    this.photoUrl = "",
    this.lastUpdated,
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      id: doc.id,
      name: data['name'] ?? '',
      relation: data['relation'] ?? '',
      age: data['age'] ?? 0,
      allergies: List<String>.from(data['allergies'] ?? []),
      photoUrl: data['photoUrl'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'age': age,
      'allergies': allergies,
      'photoUrl': photoUrl,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

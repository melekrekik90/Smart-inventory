import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_inventory_new/profiles/models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _profilesRef {
    final uid = currentUserId;
    if (uid == null) throw Exception("Utilisateur non connecté");
    return _firestore.collection('users').doc(uid).collection('profiles');
  }

  // Obtenir tous les profils (Stream)
  Stream<List<ProfileModel>> getProfilesStream() {
    if (currentUserId == null) return const Stream.empty();
    return _profilesRef.orderBy('lastUpdated', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProfileModel.fromFirestore(doc)).toList();
    });
  }

  // Obtenir un profil par ID (Future pour accès unique)
  Future<ProfileModel?> getProfileById(String profileId) async {
    try {
      final doc = await _profilesRef.doc(profileId).get();
      if (doc.exists) {
        return ProfileModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Obtenir un profil par ID (Stream pour mise à jour en temps réel)
  Stream<ProfileModel?> getProfileStreamById(String profileId) {
    return _profilesRef.doc(profileId).snapshots().map((doc) {
      if (doc.exists) {
        return ProfileModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Ajouter ou mettre à jour un profil
  Future<void> saveProfile(ProfileModel profile) async {
    if (profile.id.isNotEmpty) {
      await _profilesRef.doc(profile.id).update(profile.toMap());
    } else {
      await _profilesRef.add(profile.toMap());
    }
  }

  // Supprimer un profil
  Future<void> deleteProfile(String profileId) async {
    await _profilesRef.doc(profileId).delete();
  }
}

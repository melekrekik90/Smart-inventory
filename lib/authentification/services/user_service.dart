import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<DocumentSnapshot> getUserDataStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // --- FONCTIONS DE MISE À JOUR ---

  Future<String?> updateName(String newName) async {
    try {
      final uid = currentUserId;
      if (uid == null) return "Utilisateur non connecté.";
      await _firestore.collection('users').doc(uid).update({'name': newName});
      return null; // Succès
    } catch (e) {
      return "Erreur lors de la mise à jour du nom.";
    }
  }

  Future<String?> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Utilisateur non connecté.";
      
      // Dans les versions récentes de Firebase, updateEmail n'existe plus. 
      // Il faut utiliser verifyBeforeUpdateEmail (qui envoie un lien au nouvel email)
      await user.verifyBeforeUpdateEmail(newEmail); 
      
      // Mettre à jour l'email dans la collection users aussi
      await _firestore.collection('users').doc(user.uid).update({'email': newEmail});
      return null;
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        return "Pour des raisons de sécurité, veuillez vous déconnecter et vous reconnecter pour changer d'email.";
      }
      return "Erreur lors de la mise à jour de l'email.";
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Utilisateur non connecté.";
      await user.updatePassword(newPassword);
      return null;
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        return "Pour des raisons de sécurité, veuillez vous déconnecter et vous reconnecter pour changer de mot de passe.";
      }
      return "Erreur lors de la mise à jour du mot de passe.";
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_history_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _scanHistoryRef {
    final uid = currentUserId;
    if (uid == null) throw Exception("Utilisateur non connecté");
    return _firestore.collection('users').doc(uid).collection('scan_history');
  }

  Stream<List<ScanHistoryModel>> getScanHistoryStream() {
    if (currentUserId == null) return const Stream.empty();
    return _scanHistoryRef.orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ScanHistoryModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> decrementerQuantite(String docId, int currentQty) async {
    if (currentQty <= 0) return;
    await _scanHistoryRef.doc(docId).update({'nbUnites': currentQty - 1});
  }

  Future<void> supprimerProduit(String docId) async {
    await _scanHistoryRef.doc(docId).delete();
  }
}

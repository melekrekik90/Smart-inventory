import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProduitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> enregistrerProduits(List<Map<String, dynamic>> products) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || products.isEmpty) return;

    final batch = _firestore.batch();

    // 1. On récupère d'abord l'historique actuel pour trouver les anciens produits (qui ont des IDs aléatoires)
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('scan_history')
        .get();
        
    // Création d'une map pour trouver rapidement le produit par son nom
    Map<String, DocumentReference> existingProducts = {};
    for (var doc in snapshot.docs) {
      String pName = (doc.data()['productName'] ?? '').toString().toUpperCase();
      existingProducts[pName] = doc.reference;
    }

    for (var p in products) {
      String docName = p['name'].toString().trim().toUpperCase();
      if (docName.isEmpty) continue;

      // Nettoyer le nom pour l'utiliser comme ID de document Firestore
      String safeDocId = docName.replaceAll('/', '_');

      // 1. Mise à jour collection globale 'produit'
      DocumentReference prodRef = _firestore.collection('produit').doc(safeDocId);
      batch.set(prodRef, {
        'nom': docName,
        'quantite': "", 
        'derniere_maj': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Ajout ou mise à jour dans 'users' > uid > 'scan_history'
      DocumentReference userHistoryRef;
      bool isNew = false;
      
      if (existingProducts.containsKey(docName)) {
        // Le produit existe déjà avec un vieil ID, on réutilise sa référence !
        userHistoryRef = existingProducts[docName]!;
      } else {
        // C'est un produit totalement nouveau
        userHistoryRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('scan_history')
            .doc(safeDocId);
        isNew = true;
      }

      final dataToSave = <String, dynamic>{
        'productName': docName,
        'nbUnites': FieldValue.increment(p['quantity']), 
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isNew) {
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
        dataToSave['productId'] = safeDocId;
        // On l'ajoute à la map au cas où le produit apparaîtrait 2 fois dans la même liste
        existingProducts[docName] = userHistoryRef;
      }

      batch.set(userHistoryRef, dataToSave, SetOptions(merge: true));
    }

    await batch.commit();
  }
}

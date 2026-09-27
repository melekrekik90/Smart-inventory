import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_inventory_new/notes/models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get _notesRef {
    final uid = currentUserId;
    if (uid == null) throw Exception("Utilisateur non connecté");
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Stream<List<NoteModel>> getNotesStream() {
    if (currentUserId == null) return const Stream.empty();
    return _notesRef.orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> saveNote(NoteModel note) async {
    if (note.id.isNotEmpty) {
      await _notesRef.doc(note.id).update(note.toMap());
    } else {
      await _notesRef.add(note.toMap());
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }
}

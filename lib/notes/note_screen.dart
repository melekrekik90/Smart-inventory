import 'package:flutter/material.dart';
import 'models/note_model.dart';
import 'services/note_service.dart';
import 'note_by_id_screen.dart';

class NoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NoteModel>>(
      stream: NoteService().getNotesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final notes = snapshot.data!;

        if (notes.isEmpty) return _buildEmptyState();

        return Column(
          children: notes.map((note) {
            bool isUrgent = note.isUrgent;

            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => NoteByIdScreen(note: note),
              )),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red[50] : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: isUrgent ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5) : null,
                  boxShadow: [
                    BoxShadow(
                      color: isUrgent ? Colors.red.withOpacity(0.12) : Colors.black.withOpacity(0.04),
                      blurRadius: 15, offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.redAccent : Colors.blueAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isUrgent ? Icons.priority_high : Icons.description_outlined, 
                                 color: isUrgent ? Colors.white : Colors.blueAccent, size: 20),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Note pour ${note.targetProfileName}", 
                              style: TextStyle(fontSize: 11, color: isUrgent ? Colors.red : Colors.blueGrey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          Text(note.title, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: const Center(child: Text("Aucune note dans votre Notebook", style: TextStyle(color: Colors.grey))),
  );
}
import 'package:flutter/material.dart';
import 'models/note_model.dart';
import 'services/note_service.dart';

class NoteByIdScreen extends StatefulWidget {
  final NoteModel note;

  const NoteByIdScreen({super.key, required this.note});

  @override
  State<NoteByIdScreen> createState() => _NoteByIdScreenState();
}

class _NoteByIdScreenState extends State<NoteByIdScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isUrgent;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _isUrgent = widget.note.isUrgent;
  }

  // --- LOGIQUE : MISE À JOUR ---
  void _updateNote() async {
    final updatedNote = NoteModel(
      id: widget.note.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isUrgent: _isUrgent,
      targetProfileId: widget.note.targetProfileId,
      targetProfileName: widget.note.targetProfileName,
    );
    await NoteService().saveNote(updatedNote);
    if (mounted) Navigator.pop(context);
  }

  // --- LOGIQUE : SUPPRESSION + REDIRECTION ---
  void _confirmDelete() async {

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer cette note ?"),
        content: const Text("Cette action effacera définitivement la note du Notebook."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await NoteService().deleteNote(widget.note.id);
      
      if (mounted) {
        // Redirection vers le Home (vide la pile de navigation jusqu'au premier écran)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color cardColor = Theme.of(context).cardColor;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Profil (Design moderne)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Profil : ${widget.note.targetProfileName}",
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Champ Titre (Style épuré)
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
              decoration: InputDecoration(
                hintText: "Titre de la note",
                hintStyle: TextStyle(color: textColor.withOpacity(0.2)),
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 30, thickness: 1),

            // Zone de contenu avec ombre "Soft Shadow"
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.05),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 12,
                style: TextStyle(color: textColor, height: 1.5, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Détails de votre note...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Switch Urgent Moderne
            Container(
              decoration: BoxDecoration(
                color: _isUrgent ? Colors.redAccent.withOpacity(0.05) : cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(18),
                border: _isUrgent ? Border.all(color: Colors.redAccent.withOpacity(0.3)) : null,
              ),
              child: SwitchListTile(
                title: Text("Marquer comme Urgent", 
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
                secondary: Icon(Icons.bolt_rounded, color: _isUrgent ? Colors.redAccent : Colors.grey),
                value: _isUrgent,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _isUrgent = v),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton de Sauvegarde
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                ),
                onPressed: _updateNote,
                child: const Text("Enregistrer les modifications", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
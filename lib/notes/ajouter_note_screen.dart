import 'package:flutter/material.dart';
import 'models/note_model.dart';
import 'services/note_service.dart';
import '../profiles/models/profile_model.dart';
import '../profiles/services/profile_service.dart';

class AjouterNoteScreen extends StatefulWidget {
  @override
  _AjouterNoteScreenState createState() => _AjouterNoteScreenState();
}

class _AjouterNoteScreenState extends State<AjouterNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isUrgent = false;
  String? _selectedProfileId;
  String? _selectedProfileName;

  void _addNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    
    final note = NoteModel(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isUrgent: _isUrgent,
      targetProfileId: _selectedProfileId,
      targetProfileName: _selectedProfileName ?? "Général",
    );
    await NoteService().saveNote(note);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des couleurs du thème actuel (Sombre ou Clair)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Créer une Note", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Titre", textColor),
            TextField(
              controller: _titleController,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration("Ex: Rappel Sucre...", cardColor, isDarkMode),
            ),
            const SizedBox(height: 20),
            _buildLabel("Membre concerné", textColor),
            StreamBuilder<List<ProfileModel>>(
              stream: ProfileService().getProfilesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                var profiles = snapshot.data!;
                return DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration("Choisir un profil", cardColor, isDarkMode),
                  value: _selectedProfileId,
                  items: profiles.map((profile) => DropdownMenuItem(value: profile.id, child: Text(profile.name, style: TextStyle(color: textColor)))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProfileId = val;
                      _selectedProfileName = profiles.firstWhere((p) => p.id == val).name;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("Contenu", textColor),
            TextField(
              controller: _contentController,
              maxLines: 5,
              style: TextStyle(color: textColor),
              decoration: _inputDecoration("Détails...", cardColor, isDarkMode),
            ),
            SwitchListTile(
              title: Text("Urgent", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              value: _isUrgent,
              activeColor: Colors.redAccent,
              onChanged: (v) => setState(() => _isUrgent = v),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _addNote,
                child: const Text("Enregistrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, Color fillColor, bool isDark) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
    filled: true,
    fillColor: fillColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
  );

  Widget _buildLabel(String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.7))),
  );
}
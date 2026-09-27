import 'package:flutter/material.dart';
import 'models/profile_model.dart';
import 'services/profile_service.dart';

class AjouterProfilesScreen extends StatefulWidget {
  const AjouterProfilesScreen({super.key});

  @override
  State<AjouterProfilesScreen> createState() => _AjouterProfilesScreenState();
}

class _AjouterProfilesScreenState extends State<AjouterProfilesScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _allergyController = TextEditingController();
  
  String? selectedRelation;
  List<String> allergies = [];
  String? profileId; 
  bool isInitialized = false;
  bool isLoading = false; 

  final List<String> relations = ["Père", "Mère", "Grand-père", "Grand-mère", "Fils", "Fillette", "Frére", "Soeur"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        profileId = args['id']; 
        _nameController.text = args['name'] ?? '';
        _ageController.text = args['age']?.toString() ?? '';
        selectedRelation = args['relation'];
        allergies = List<String>.from(args['allergies'] ?? []);
      }
      isInitialized = true;
    }
  }

  Future<void> saveProfile() async {
    if (_nameController.text.trim().isEmpty || selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom et la relation sont obligatoires")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final profile = ProfileModel(
        id: profileId ?? '',
        name: _nameController.text.trim(),
        relation: selectedRelation!,
        age: int.tryParse(_ageController.text) ?? 0,
        allergies: allergies,
      );

      await ProfileService().saveProfile(profile);

      // REDIRECTION : On force le retour immédiatement après le succès
      if (mounted) {
        setState(() => isLoading = false);
        
        // On utilise pop pour revenir à l'écran précédent (la liste)
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileId != null ? "Mis à jour !" : "Créé !"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isEditing = profileId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Modifier le Profil" : "Nouveau Profil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Informations générales", isDark),
            _buildModernField(controller: _nameController, label: "Nom complet", icon: Icons.person_outline),
            const SizedBox(height: 20),
            _buildDropdownField(),
            const SizedBox(height: 20),
            _buildModernField(controller: _ageController, label: "Âge", icon: Icons.cake_outlined, isNumber: true),
            const SizedBox(height: 30),
            _buildSectionTitle("Santé & Allergies", isDark),
            _buildAllergyInput(),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergies.map((a) => Chip(
                label: Text(a),
                onDeleted: () => setState(() => allergies.remove(a)),
                backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              )).toList(),
            ),
            const SizedBox(height: 40),
            _buildSaveButton(isEditing),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
    );
  }

  Widget _buildModernField({required TextEditingController controller, required String label, required IconData icon, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRelation,
          hint: const Text("Relation familiale"),
          isExpanded: true,
          items: relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (val) => setState(() => selectedRelation = val),
        ),
      ),
    );
  }

  Widget _buildAllergyInput() {
    return Row(
      children: [
        Expanded(child: _buildModernField(controller: _allergyController, label: "Ajouter une allergie", icon: Icons.health_and_safety_outlined)),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF10B981), size: 40),
          onPressed: () {
            if (_allergyController.text.isNotEmpty) {
              setState(() {
                allergies.add(_allergyController.text.trim());
                _allergyController.clear();
              });
            }
          },
        )
      ],
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEditing ? const Color(0xFF10B981) : const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: isLoading ? null : saveProfile,
        child: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(isEditing ? "Mettre à jour" : "Créer le profil", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
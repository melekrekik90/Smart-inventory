import 'package:flutter/material.dart';
import 'models/profile_model.dart';
import 'services/profile_service.dart';

class ProfilesByIdScreen extends StatelessWidget {
  final String profileId;
  
  const ProfilesByIdScreen({super.key, required this.profileId});

 Future<void> deleteProfile(BuildContext context) async {
    // 1. On capture le Navigator de l'application (pas celui du dialogue)
    final navigator = Navigator.of(context);

    try {
      await ProfileService().deleteProfile(profileId);

      // 2. On ferme TOUT et on retourne à la liste des profils
      if (context.mounted) {
        // Cette commande vide la pile et force le retour à la liste
        navigator.pushNamedAndRemoveUntil('/profiles', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil supprimé avec succès"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de la suppression: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileModel?>(
      future: ProfileService().getProfileById(profileId),
      builder: (context, snapshot) {
        // Gestion de l'état de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Gestion d'erreur ou document inexistant
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erreur")),
            body: const Center(child: Text("Profil introuvable")),
          );
        }

        // Extraction des données du snapshot
        var profile = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Détails du membre"),
            actions: [
              // BOUTON ÉDITER
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    '/add_profile', // Vérifie bien que c'est le nom de ta route
                    arguments: {
                      'id': profile.id,
                      'name': profile.name,
                      'relation': profile.relation,
                      'age': profile.age,
                      'allergies': profile.allergies,
                    },
                  );
                },
              ),
              // BOUTON SUPPRIMER
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // En-tête Profil
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF2563EB),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        profile.name.isEmpty ? "Sans nom" : profile.name, 
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        profile.relation.isEmpty ? "Relation non définie" : profile.relation, 
                        style: const TextStyle(fontSize: 18, color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Informations détaillées
                _buildInfoCard(
                  context,
                  title: "Âge",
                  value: "${profile.age} ans",
                  icon: Icons.cake_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 15),

                _buildAllergiesSection(context, profile.allergies),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context, List<dynamic> allergies) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: Color(0xFF10B981)),
              SizedBox(width: 15),
              Text("Allergies & Santé", style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 15),
          if (allergies.isEmpty)
            const Text("Aucune allergie répertoriée.", style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allergies.map((a) => Chip(
                label: Text(a),
                backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                side: BorderSide.none,
                labelStyle: const TextStyle(color: Color(0xFFEF4444)),
              )).toList(),
            ),
        ],
      ),
    );
  }

 void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // On nomme le context du dialogue différemment
        title: const Text("Supprimer le profil ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Ferme juste le dialogue
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Ferme le dialogue d'abord
              deleteProfile(context); // Lance la suppression avec le context de la page
            },
            child: const Text("Supprimer", style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
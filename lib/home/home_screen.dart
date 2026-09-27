import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_inventory_new/authentification/services/user_service.dart';
import 'package:smart_inventory_new/main.dart';
import 'package:smart_inventory_new/notes/ajouter_note_screen.dart';
import 'package:smart_inventory_new/notes/note_screen.dart';
import 'package:smart_inventory_new/notification/services/notification_service.dart';
import 'package:smart_inventory_new/shared/services/feedback_service.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le changement de thème ici aussi
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final l10n = AppLocalizations.of(context)!;
        bool isDark = currentMode == ThemeMode.dark;
        Color textColor = isDark ? Colors.white : const Color(0xFF111827);
        Color cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          
          // --- HEADER ---
          appBar: AppBar(
            title: Text(l10n.appTitle, 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            actions: [
              StreamBuilder<List<String>>(
                stream: NotificationService().getLowStockNotifications(),
                builder: (context, snapshot) {
                  int notifCount = snapshot.hasData ? snapshot.data!.length : 0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_rounded, color: textColor),
                        onPressed: () {
                          FeedbackService.playClickSound();
                          Navigator.pushNamed(context, '/notification');
                        },
                      ),
                      if (notifCount > 0)
                        Positioned(
                          right: 8,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notifCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded),
                onPressed: () {
                  FeedbackService.playClickSound();
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                onPressed: () async {
                  FeedbackService.playClickSound();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),

          // --- DRAWER ---
          drawer: Drawer(
            backgroundColor: cardColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF10B981)])
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white, 
                        child: Icon(Icons.person, color: Color(0xFF2563EB))
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<DocumentSnapshot>(
                        stream: UserService().getUserDataStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            String name = snapshot.data!['name'] ?? "Utilisateur";
                            return Text(name, 
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                          }
                          return const Text("Chargement...", 
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                        },
                      ),
                      Text(FirebaseAuth.instance.currentUser?.email ?? "", 
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                _buildDrawerItem(
  context, 
  Icons.dashboard_rounded, 
  l10n.dashboard, 
  () => Navigator.pushNamed(context, '/dashboard'),
  textColor
),
                _buildDrawerItem(context, Icons.people_alt_rounded, l10n.myProfiles, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profiles');
                }, textColor),
                _buildDrawerItem(context, Icons.person_add_rounded, l10n.addMember, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add_profile');
                }, textColor),
                _buildDrawerItem(context, Icons.book_rounded, l10n.notebook, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/ajouter_note');
                }, textColor),
                const Divider(),
                _buildDrawerItem(context, Icons.settings_rounded, l10n.settings, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/parametres');
                }, textColor),
                _buildDrawerItem(context, Icons.info_outline_rounded, l10n.about, () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/a_propos');
                }, textColor),
              ],
            ),
          ),

          // --- BODY ---
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scanModes, 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 15),
                
                _buildModeCard(
                  title: l10n.modeRapide,
                  subtitle: l10n.modeRapideSubtitle,
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.pushNamed(context, '/scan-ticket'),
                ),
                const SizedBox(height: 15),

                _buildModeCard(
                  title: l10n.modeSante,
                  subtitle: l10n.modeSanteSubtitle,
                  icon: Icons.health_and_safety_rounded,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/scan-ingredient'),
                ),
                _buildModeCard(
                  title: l10n.modePhoto,
                  subtitle: l10n.modePhotoSubtitle,
                  icon: Icons.camera_enhance_rounded,
                  color: Colors.purpleAccent,
                  onTap: () => Navigator.pushNamed(context, '/mode-photo'),
                ),

                const SizedBox(height: 30),
                 Text(
                  l10n.myNotes, 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)
                   ),
               const SizedBox(height: 10),


                  NoteScreen(), 

                 const SizedBox(height: 20), // Espace après la liste
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),   // injection de service 
      onTap: () {
        FeedbackService.playClickSound();
        onTap();
      },
    );
  }

 Widget _buildModeCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap, // Ajout du callback pour le clic
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15), // Espacement entre les cartes
    child: InkWell(
      onTap: () {
        FeedbackService.playClickSound();
        onTap();
      }, // Déclenche la navigation ou l'action
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 20),
            Expanded( // Ajout de Expanded pour éviter les débordements de texte
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
}
}
import 'package:flutter/material.dart';
import 'package:smart_inventory_new/main.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        bool isDark = currentMode == ThemeMode.dark;
        Color textColor = isDark ? Colors.white : const Color(0xFF111827);
        Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF4B5563);
        Color cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.about,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            iconTheme: IconThemeData(color: textColor),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo ou Icône de l'application
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 80,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  l10n.version,
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Section Description
                _buildInfoCard(
                  title: l10n.aboutApp,
                  content: l10n.aboutAppDesc,
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                
                const SizedBox(height: 20),
                
                // Section Technologies / APIs
                _buildInfoCard(
                  title: l10n.techApis,
                  content: "• Google ML Kit : Pour la reconnaissance de texte (OCR), l'étiquetage d'images et la traduction automatique.\n"
                           "• Firebase : Pour l'authentification sécurisée et le stockage des données (Cloud Firestore).\n"
                           "• Flutter : Framework UI pour une expérience fluide et multiplateforme.",
                  cardColor: cardColor,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  "© 2026 Smart Inventory Team",
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.madeWith,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

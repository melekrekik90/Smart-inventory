import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/scan_history_model.dart';
import 'services/dashboard_service.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Fonction pour décrémenter la quantité directement sur le document
  Future<void> _decrementerQuantite(String docId, int currentQty) async {
    if (currentQty <= 0) return;

    try {
      await DashboardService().decrementerQuantite(docId, currentQty);
    } catch (e) {
      debugPrint("Erreur décrémentation: $e");
    }
  }

  // Fonction pour supprimer le produit du stock
  Future<void> _supprimerProduit(String docId) async {
    try {
      await DashboardService().supprimerProduit(docId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produit retiré du stock")),
        );
      }
    } catch (e) {
      debugPrint("Erreur suppression: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<ScanHistoryModel>>(
        stream: DashboardService().getScanHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(textColor);
          }

          final items = snapshot.data!;
          
          // Calculs des stats
          int totalScans = items.length;
          double totalUnites = items.fold(0, (sum, item) {
            return sum + item.nbUnites;
          });

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  _buildStatCard(l10n.totalScans, totalScans.toString(), Icons.qr_code_scanner, Colors.blueAccent, context),
                  const SizedBox(width: 15),
                  _buildStatCard(l10n.articles, totalUnites.toInt().toString(), Icons.inventory_2, Colors.orangeAccent, context),
                ],
              ),
              const SizedBox(height: 30),
              
              Text(l10n.currentStock, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildHistoryItem(item, context, textColor);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ScanHistoryModel item, BuildContext context, Color textColor) {
    final date = item.createdAt ?? DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    final int qty = item.nbUnites;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            child: const Icon(Icons.inventory, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName.isEmpty ? AppLocalizations.of(context)!.unknown : item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          
          // Action: Décrémenter
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.orange, size: 22),
            onPressed: () => _decrementerQuantite(item.id, qty),
          ),

          // Affichage Quantité
          Text(
            "$qty",
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
          ),

          // Action: Supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            onPressed: () => _showDeleteDialog(item.id, item.productName),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String docId, String productName) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              _supprimerProduit(docId);
              Navigator.pop(context);
            }, 
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.noStock, style: TextStyle(color: textColor.withOpacity(0.5))),
        ],
      ),
    );
  }
}
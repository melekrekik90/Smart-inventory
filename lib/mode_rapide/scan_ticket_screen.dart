import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ocr_service.dart'; 
import 'package:smart_inventory_new/shared/services/feedback_service.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  File? _image;
  bool _isProcessing = false;
  String _statusMessage = "Analyse du ticket...";
  
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 95, 
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
        _statusMessage = "L'IA analyse le texte...";
      });

      try {
        // Étape 1 & 2 : OCR + Traduction via le service
        final List<Map<String, dynamic>> results = await _ocrService.extractProductsFromImage(_image!);
        
        if (!mounted) return;

        if (results.isNotEmpty) {
          FeedbackService.playScanVibration();
          setState(() {
            _statusMessage = "Traduction terminée !";
            _isProcessing = false;
          });

          // Navigation vers l'écran d'ajout avec les données traduites
          Navigator.pushNamed(
            context, 
            '/ajouter-produit', 
            arguments: results 
          );
        } else {
          setState(() => _isProcessing = false);
          _showSnackBar("Aucun produit détecté sur ce ticket.");
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        _showSnackBar("Erreur de l'IA (Vérifiez votre connexion pour le pack de langue) : $e");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null
                  ? _buildEmptyState()
                  : _buildImagePreview(),
            ),
          ),

          if (_isProcessing) _buildLoader(),

          _buildBottomPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.blueAccent.withOpacity(0.3)),
        const SizedBox(height: 15),
        Text(
          l10n.scanEmptyTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          l10n.scanEmptySubtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(_image!),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.blueAccent),
          const SizedBox(height: 10),
          Text(_statusMessage, style: const TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.camera_alt_rounded,
              label: AppLocalizations.of(context)!.camera,
              color: Colors.blueAccent,
              onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _actionButton(
              icon: Icons.photo_library_rounded,
              label: AppLocalizations.of(context)!.gallery,
              color: Colors.blueGrey,
              onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
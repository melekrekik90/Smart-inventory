import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'ocr_sante_service.dart';
import 'package:smart_inventory_new/shared/services/feedback_service.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class ScanIngredientScreen extends StatefulWidget {
  const ScanIngredientScreen({super.key});

  @override
  State<ScanIngredientScreen> createState() => _ScanIngredientScreenState();
}

class _ScanIngredientScreenState extends State<ScanIngredientScreen> {
  final OCRSanteService _ocrService = OCRSanteService();
  final ImagePicker _picker = ImagePicker();
  
  File? _image;
  bool _isProcessing = false;
  Map<String, List<String>> _alerts = {};

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 95);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isProcessing = true;
      _alerts = {}; 
    });

    try {
      // Les deux IA travaillent ici (OCR + Traduction)
      final results = await _ocrService.scanAndCheck(pickedFile.path);
      
      FeedbackService.playScanVibration();

      if (!mounted) return;
      setState(() {
        _alerts = results;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur IA : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthModeTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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

          if (_isProcessing) 
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                ],
              ),
            ),

          if (!_isProcessing && _alerts.isNotEmpty) _buildAlertList(textColor),

          if (!_isProcessing && _image != null && _alerts.isEmpty) _buildSafeMessage(),

          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.health_and_safety_outlined, size: 70, color: Colors.green),
        const SizedBox(height: 15),
        Text(l10n.healthEmptyTitle, style: const TextStyle(fontSize: 16)),
        Text(l10n.healthEmptySubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _alerts.isNotEmpty ? Colors.red : Colors.green,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.file(_image!, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _btn(Icons.camera_alt, AppLocalizations.of(context)!.camera, Colors.green, () => _pickAndScan(ImageSource.camera)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _btn(Icons.image, AppLocalizations.of(context)!.gallery, Colors.blueGrey, () => _pickAndScan(ImageSource.gallery)),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback? action) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : action,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAlertList(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text("DANGER DÉTECTÉ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          ..._alerts.entries.map((entry) => Card(
                elevation: 0,
                color: Colors.red.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  subtitle: Text("Allergènes : ${entry.value.join(', ')}"),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSafeMessage() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Colors.green,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(l10n.safeProduct, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
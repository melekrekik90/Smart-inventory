import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/image_labeling_service.dart';
import 'package:smart_inventory_new/shared/services/feedback_service.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';

class ModePhotoScreen extends StatefulWidget {
  const ModePhotoScreen({super.key});

  @override
  State<ModePhotoScreen> createState() => _ModePhotoScreenState();
}

class _ModePhotoScreenState extends State<ModePhotoScreen> {
  File? _image;
  bool _isProcessing = false;
  String _statusMessage = "Analyse de l'image...";
  
  final ImagePicker _picker = ImagePicker();
  final ImageLabelingService _labelingService = ImageLabelingService();

  @override
  void dispose() {
    _labelingService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 95);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
        _statusMessage = "L'IA identifie l'objet...";
      });

      try {
        final List<String> detectedNames = await _labelingService.detectProductFromImage(_image!);
        
        if (!mounted) return;

        if (detectedNames.isNotEmpty) {
          FeedbackService.playScanVibration();
          setState(() {
            _statusMessage = "Analyse terminée.";
            _isProcessing = false;
          });

          if (detectedNames.length > 1) {
            _showSelectionDialog(detectedNames);
          } else {
            _navigateToAjouter(detectedNames.first);
          }
        } else {
          setState(() => _isProcessing = false);
          _showSnackBar("Aucun objet clairement identifié.");
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        _showSnackBar("Erreur de l'IA : $e");
      }
    }
  }

  void _showSelectionDialog(List<String> names) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          const Text("Qu'avez-vous pris en photo ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...names.map((name) => ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.purpleAccent),
                title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAjouter(name);
                },
              )),
            ],
          ),
        );
      }
    );
  }

  void _navigateToAjouter(String name) {
    Navigator.pushNamed(
      context, 
      '/ajouter-produit', 
      arguments: [{'name': name.toUpperCase(), 'quantity': 1}] 
    );
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
        title: Text(l10n.photoModeTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        Icon(Icons.camera_enhance_outlined, size: 80, color: Colors.purpleAccent.withOpacity(0.3)),
        const SizedBox(height: 15),
        Text(
          l10n.photoEmptyTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          l10n.photoEmptySubtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: const BoxDecoration(
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
          const CircularProgressIndicator(color: Colors.purpleAccent),
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.camera_alt_rounded,
              label: AppLocalizations.of(context)!.camera,
              color: Colors.purpleAccent,
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

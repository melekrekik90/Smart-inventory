import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart'; // Ajoute cette dépendance

class OCRService {
  // IA 1 : Reconnaissance de texte
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // IA 2 : Identificateur de langue (pour savoir si c'est EN ou AR)
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  Future<List<Map<String, dynamic>>> extractProductsFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    List<Map<String, dynamic>> detectedItems = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String cleanName = _processLineText(line.text);

        if (_isValidProductLine(cleanName)) {
          // --- LOGIQUE DE TRADUCTION INTELLIGENTE ---
          String finalName = await _translateIfNeeded(cleanName);

          detectedItems.add({
            'name': finalName.toUpperCase(),
            'quantity': _extractQuantity(line.text),
          });
        }
      }
    }
    return _mergeDuplicates(detectedItems);
  }

  // Fonction pour traduire seulement si ce n'est pas du français
Future<String> _translateIfNeeded(String text) async {
    final String langCode = await _languageIdentifier.identifyLanguage(text);

    // Si c'est déjà du Français ('fr') ou si l'IA ne reconnaît pas ('und'), on ne traduit pas
    if (langCode == 'fr' || langCode == 'und') {
      return text;
    }

    // On convertit le code (ex: 'ar') en type TranslateLanguage
    final sourceLang = _mapCodeToLanguage(langCode);
    
    // Si la langue n'est pas supportée par notre logique, on garde le texte original
    if (sourceLang == null) return text;

    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: TranslateLanguage.french,
    );

    try {
      final translatedText = await translator.translateText(text);
      await translator.close(); // Important : toujours fermer le traducteur dynamique
      return translatedText;
    } catch (e) {
      return text; 
    }
  }

  // Fonction de mapping manuelle (plus stable que bcp47Code)
  TranslateLanguage? _mapCodeToLanguage(String code) {
    switch (code) {
      case 'ar': return TranslateLanguage.arabic;
      case 'en': return TranslateLanguage.english;
      case 'de': return TranslateLanguage.german;
      case 'it': return TranslateLanguage.italian;
      case 'es': return TranslateLanguage.spanish;
      default: return null; // Ajoute d'autres langues si besoin
    }
  }

  // --- Fonctions utilitaires ---

  int _extractQuantity(String text) {
    final RegExp qtyRegExp = RegExp(r'^(\d+)\s+');
    final match = qtyRegExp.firstMatch(text);
    return (match != null) ? int.parse(match.group(1)!) : 1;
  }

  String _processLineText(String rawText) {
    // Retire la quantité au début et les prix à la fin
    String name = rawText.replaceFirst(RegExp(r'^\d+\s+'), '');
    name = name.replaceAll(RegExp(r'\d+[\.,]\d{3}'), '').trim();
    return _cleanText(name);
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'[^\w\sàâäéèêëïîôöùûüç\u0600-\u06FF]'), ' ')
               .replaceAll(RegExp(r'\s+'), ' ')
               .trim();
  }

  bool _isValidProductLine(String line) {
    if (line.length < 3) return false;
    List<String> blacklist = ["total", "merci", "tva", "magasin", "mg", "espèces", "rendu", "caissier", "date"];
    return !blacklist.any((word) => line.toLowerCase().contains(word));
  }

  List<Map<String, dynamic>> _mergeDuplicates(List<Map<String, dynamic>> items) {
    final Map<String, int> merged = {};
    for (var item in items) {
      merged[item['name']] = (merged[item['name']] ?? 0) + (item['quantity'] as int);
    }
    return merged.entries.map((e) => {'name': e.key, 'quantity': e.value}).toList();
  }

  void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
  }
}
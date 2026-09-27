import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OCRSanteService {
  // IA 1 : Reconnaissance de texte
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // IA 2 : Identification de langue et Traduction
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  Future<List<Map<String, dynamic>>> _getAllergiesProfiles() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, List<String>>> scanAndCheck(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    // 1. Extraire et traduire le texte si nécessaire
    String textAAnalyse = await _getTranslatedText(recognizedText.text);
    final String fullTextLower = textAAnalyse.toLowerCase();
    
    final profiles = await _getAllergiesProfiles();
    Map<String, List<String>> alerts = {};

    for (var profile in profiles) {
      String displayName = profile['name'] ?? "Profil sans nom"; 
      List<dynamic> allergies = profile['allergies'] ?? [];
      List<String> dangerFound = [];

      for (var allergie in allergies) {
        String allergieStr = allergie.toString().toLowerCase().trim();
        // Détection intelligente : on cherche si l'allergène est présent dans le texte traduit
        if (allergieStr.isNotEmpty && fullTextLower.contains(allergieStr)) {
          dangerFound.add(allergie.toString());
        }
      }

      if (dangerFound.isNotEmpty) {
        alerts[displayName] = dangerFound;
      }
    }

    return alerts;
  }

  // Logique de traduction automatique pour les ingrédients
  Future<String> _getTranslatedText(String originalText) async {
    final String langCode = await _languageIdentifier.identifyLanguage(originalText);
    
    // Si c'est déjà en français, on ne traduit pas
    if (langCode == 'fr' || langCode == 'und') return originalText;

    final sourceLang = _mapCodeToLanguage(langCode);
    if (sourceLang == null) return originalText;

    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: TranslateLanguage.french,
    );

    try {
      final translatedText = await translator.translateText(originalText);
      await translator.close();
      return translatedText;
    } catch (e) {
      return originalText;
    }
  }

  TranslateLanguage? _mapCodeToLanguage(String code) {
    switch (code) {
      case 'ar': return TranslateLanguage.arabic;
      case 'en': return TranslateLanguage.english;
      default: return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
  }
}
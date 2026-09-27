import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class ImageLabelingService {
  final ImageLabeler _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.1));
  
  // Le modèle de base d'Image Labeling retourne des mots en anglais. On va les traduire en français.
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.french,
  );

  Future<List<String>> detectProductFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

    if (labels.isEmpty) return [];

    List<String> validLabels = [];

    // On prend simplement les 3 meilleurs résultats, SANS AUCUN FILTRE
    for (var label in labels) {
      validLabels.add(label.label);
      if (validLabels.length >= 3) break;
    }

    List<String> frenchLabels = [];
    for (var engLabel in validLabels) {
      try {
        final frenchLabel = await _translator.translateText(engLabel);
        frenchLabels.add(frenchLabel);
      } catch (e) {
        frenchLabels.add(engLabel); // Retour de secours
      }
    }

    return frenchLabels;
  }

  void dispose() {
    _imageLabeler.close();
    _translator.close();
  }
}

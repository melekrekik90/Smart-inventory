import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Smart Inventory'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @soundEffects.
  ///
  /// In fr, this message translates to:
  /// **'Effets sonores'**
  String get soundEffects;

  /// No description provided for @soundDesc.
  ///
  /// In fr, this message translates to:
  /// **'Sons lors des clics et actions'**
  String get soundDesc;

  /// No description provided for @vibrations.
  ///
  /// In fr, this message translates to:
  /// **'Vibrations'**
  String get vibrations;

  /// No description provided for @vibrationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Retour haptique lors des scans'**
  String get vibrationDesc;

  /// No description provided for @personalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations Personnelles'**
  String get personalInfo;

  /// No description provided for @appPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences de l\'application'**
  String get appPreferences;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès !'**
  String get profileUpdated;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @myProfiles.
  ///
  /// In fr, this message translates to:
  /// **'Mes Profils'**
  String get myProfiles;

  /// No description provided for @addMember.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get addMember;

  /// No description provided for @notebook.
  ///
  /// In fr, this message translates to:
  /// **'Notebook (Notes)'**
  String get notebook;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @scanModes.
  ///
  /// In fr, this message translates to:
  /// **'Modes de Scan'**
  String get scanModes;

  /// No description provided for @modeRapide.
  ///
  /// In fr, this message translates to:
  /// **'Mode Rapide'**
  String get modeRapide;

  /// No description provided for @modeRapideSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Scan de ticket supermarché'**
  String get modeRapideSubtitle;

  /// No description provided for @modeSante.
  ///
  /// In fr, this message translates to:
  /// **'Mode Santé'**
  String get modeSante;

  /// No description provided for @modeSanteSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les ingrédients (Détection d\'allergènes)'**
  String get modeSanteSubtitle;

  /// No description provided for @modePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Mode Photo'**
  String get modePhoto;

  /// No description provided for @modePhotoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Détection d\'objets (Reconnaissance sans texte)'**
  String get modePhotoSubtitle;

  /// No description provided for @myNotes.
  ///
  /// In fr, this message translates to:
  /// **'Mes Notes (Notebook)'**
  String get myNotes;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom Complet'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse Email'**
  String get emailAddress;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Mot de passe (optionnel)'**
  String get newPassword;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotifications;

  /// No description provided for @stockOk.
  ///
  /// In fr, this message translates to:
  /// **'Vos stocks sont suffisants.'**
  String get stockOk;

  /// No description provided for @aboutApp.
  ///
  /// In fr, this message translates to:
  /// **'L\'application'**
  String get aboutApp;

  /// No description provided for @aboutAppDesc.
  ///
  /// In fr, this message translates to:
  /// **'Smart Inventory est une solution innovante de gestion d\'inventaire personnel. Elle utilise l\'intelligence artificielle pour simplifier la saisie des produits et le suivi des stocks en temps réel.'**
  String get aboutAppDesc;

  /// No description provided for @techApis.
  ///
  /// In fr, this message translates to:
  /// **'Technologies & APIs'**
  String get techApis;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @madeWith.
  ///
  /// In fr, this message translates to:
  /// **'Fait avec ❤️ pour simplifier votre quotidien.'**
  String get madeWith;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scan Rapide (Multi-IA)'**
  String get scanTitle;

  /// No description provided for @scanEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un ticket (Arabe ou Français)'**
  String get scanEmptyTitle;

  /// No description provided for @scanEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA traduira automatiquement les articles'**
  String get scanEmptySubtitle;

  /// No description provided for @analyzeImage.
  ///
  /// In fr, this message translates to:
  /// **'Analyse du ticket...'**
  String get analyzeImage;

  /// No description provided for @aiAnalyzing.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA analyse le texte...'**
  String get aiAnalyzing;

  /// No description provided for @translationDone.
  ///
  /// In fr, this message translates to:
  /// **'Traduction terminée !'**
  String get translationDone;

  /// No description provided for @noProductDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit détecté sur ce ticket.'**
  String get noProductDetected;

  /// No description provided for @camera.
  ///
  /// In fr, this message translates to:
  /// **'Caméra'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get gallery;

  /// No description provided for @photoModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode Photo (IA Vision)'**
  String get photoModeTitle;

  /// No description provided for @photoEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prendre un produit en photo'**
  String get photoEmptyTitle;

  /// No description provided for @photoEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA reconnaîtra automatiquement l\'objet'**
  String get photoEmptySubtitle;

  /// No description provided for @aiIdentifying.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA identifie l\'objet...'**
  String get aiIdentifying;

  /// No description provided for @analysisComplete.
  ///
  /// In fr, this message translates to:
  /// **'Analyse terminée.'**
  String get analysisComplete;

  /// No description provided for @noObjectDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objet clairement identifié.'**
  String get noObjectDetected;

  /// No description provided for @whatDidYouPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Qu\'avez-vous pris en photo ?'**
  String get whatDidYouPhoto;

  /// No description provided for @healthModeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérificateur Santé'**
  String get healthModeTitle;

  /// No description provided for @healthEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scannez la liste des ingrédients'**
  String get healthEmptyTitle;

  /// No description provided for @healthEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA détectera les allergènes pour vous.'**
  String get healthEmptySubtitle;

  /// No description provided for @multiAiAnalyzing.
  ///
  /// In fr, this message translates to:
  /// **'Analyse multi-IA en cours...'**
  String get multiAiAnalyzing;

  /// No description provided for @dangerDetected.
  ///
  /// In fr, this message translates to:
  /// **'DANGER DÉTECTÉ'**
  String get dangerDetected;

  /// No description provided for @allergens.
  ///
  /// In fr, this message translates to:
  /// **'Allergènes'**
  String get allergens;

  /// No description provided for @safeProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit sûr pour tous les profils'**
  String get safeProduct;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de Bord'**
  String get dashboardTitle;

  /// No description provided for @totalScans.
  ///
  /// In fr, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @articles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @currentStock.
  ///
  /// In fr, this message translates to:
  /// **'Mon Stock Actuel'**
  String get currentStock;

  /// No description provided for @noStock.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit en stock'**
  String get noStock;

  /// No description provided for @productRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Produit retiré du stock'**
  String get productRemoved;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous retirer ce produit du stock ?'**
  String get confirmDelete;

  /// No description provided for @unknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknown;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez votre stock intelligemment'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? S\'inscrire'**
  String get noAccount;

  /// No description provided for @myFamily.
  ///
  /// In fr, this message translates to:
  /// **'Ma Famille'**
  String get myFamily;

  /// No description provided for @noProfile.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil membre'**
  String get noProfile;

  /// No description provided for @noProfileDesc.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par ajouter un membre de votre famille.'**
  String get noProfileDesc;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @years.
  ///
  /// In fr, this message translates to:
  /// **'ans'**
  String get years;

  /// No description provided for @dailyReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In fr, this message translates to:
  /// **'Notification de rappel à 20h00'**
  String get dailyReminderDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

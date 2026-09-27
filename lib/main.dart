import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_inventory_new/dashboard/dashboard_screen.dart';
import 'package:smart_inventory_new/mode_rapide/scan_ticket_screen.dart';
import 'package:smart_inventory_new/mode_sante/scan_ingredient_screen.dart';
import 'package:smart_inventory_new/notes/ajouter_note_screen.dart';
import 'package:smart_inventory_new/produits/ajouter_produit_screen.dart';

// Tes imports de dossiers
import 'authentification/login_screen.dart';
import 'authentification/signup_screen.dart';
import 'home/home_screen.dart';
import 'profiles/profiles_screen.dart';
import 'profiles/ajouter_profiles_screen.dart';
import 'profiles/profile_by_id_screen.dart';
import 'notification/notification_screen.dart';
import 'mode_photo/mode_photo_screen.dart';
import 'parametres/parametres_screen.dart';
import 'a_propos/a_propos_screen.dart';
import 'shared/services/language_service.dart';
import 'shared/services/push_notification_service.dart';

// Gestionnaire global du thème (accessible partout dans l'app)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);   // observer
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('fr'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialiser les notifications push en toute sécurité
  try {
    final pushService = PushNotificationService();
    await pushService.initialize();
    await pushService.scheduleDailyReminder(hour: 20, minute: 0);
  } catch (e) {
    print("Erreur d'initialisation des notifications push : $e");
  }

  String savedLang = await LanguageService.getLanguage();
  localeNotifier.value = Locale(savedLang);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(   // listener
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (_, currentLocale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Smart Inventory',
              
              locale: currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('fr'),
                Locale('en'),
                Locale('ar'),
              ],
          
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF111827),
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF3B82F6),
            scaffoldBackgroundColor: const Color(0xFF111827),
            cardColor: const Color(0xFF1F2937),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/profiles': (context) => const ProfilesScreen(),
            '/add_profile': (context) => const AjouterProfilesScreen(),
            '/ajouter_note': (context) => AjouterNoteScreen(),
            '/scan-ticket': (context) => const ScanTicketScreen(),
            '/scan-ingredient': (context) => const ScanIngredientScreen(),
            '/mode-photo': (context) => const ModePhotoScreen(),
            // '/ajouter-produit': (context) => const AjouterProduitScreen(initialProducts: [],),
            '/dashboard': (context) => const DashboardScreen(),
            '/notification': (context) => const NotificationScreen(),
            '/parametres': (context) => const ParametresScreen(),
            '/a_propos': (context) => const AProposScreen(),
          },
          
          onGenerateRoute: (settings) {
            if (settings.name == '/profile_detail') {
              final String profileId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ProfilesByIdScreen(profileId: profileId),
              );
            }
            if (settings.name == '/ajouter-produit') {
    // On récupère les données envoyées depuis scan_ticket_screen
    final args = settings.arguments as List<Map<String, dynamic>>? ?? [];
    return MaterialPageRoute(
      builder: (context) => AjouterProduitScreen(initialProducts: args),
    );
  }
            return null;
          },
          // Dans ta liste de routes dans MaterialApp
        );
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:smart_inventory_new/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_inventory_new/authentification/services/user_service.dart';
import 'package:smart_inventory_new/shared/services/feedback_service.dart';
import 'package:smart_inventory_new/shared/services/language_service.dart';
import 'package:smart_inventory_new/shared/services/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_inventory_new/main.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final UserService _userService = UserService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInit = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  bool _isDailyReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    bool sound = await FeedbackService.isSoundEnabled();
    bool vib = await FeedbackService.isVibrationEnabled();
    final prefs = await SharedPreferences.getInstance();
    bool reminder = prefs.getBool('pref_daily_reminder') ?? true;
    if (mounted) {
      setState(() {
        _isSoundEnabled = sound;
        _isVibrationEnabled = vib;
        _isDailyReminderEnabled = reminder;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool success = true;

    // Mise à jour du nom
    if (name.isNotEmpty) {
      String? err = await _userService.updateName(name);
      if (err != null) {
        _showSnackBar(err, isError: true);
        success = false;
      }
    }

    // Mise à jour de l'email
    if (email.isNotEmpty && email != FirebaseAuth.instance.currentUser?.email) {
      String? err = await _userService.updateEmail(email);
      if (err != null) {
        _showSnackBar(err, isError: true);
        success = false;
      }
    }

    // Mise à jour du mot de passe
    if (password.isNotEmpty) {
      String? err = await _userService.updatePassword(password);
      if (err != null) {
        _showSnackBar(err, isError: true);
        success = false;
      } else {
        _passwordController.clear(); // Vider le champ si succès
      }
    }

    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar("Profil mis à jour avec succès !");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userService.getUserDataStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Initialisation des champs la première fois
          if (!_isInit && snapshot.data!.exists) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
            _isInit = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.personalInfo, 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                _buildTextField(
                  controller: _nameController,
                  label: "Nom Complet",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _emailController,
                  label: "Adresse Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _passwordController,
                  label: "Nouveau Mot de passe (optionnel)",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 30),

                const SizedBox(height: 30),
                Text(l10n.appPreferences, 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                ListTile(
                  title: Text(l10n.language),
                  leading: const Icon(Icons.language, color: Colors.blueAccent),
                  trailing: DropdownButton<String>(
                    value: localeNotifier.value.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text("Français")),
                      DropdownMenuItem(value: 'en', child: Text("English")),
                      DropdownMenuItem(value: 'ar', child: Text("العربية")),
                    ],
                    onChanged: (String? newLang) async {
                      if (newLang != null) {
                        await LanguageService.setLanguage(newLang);
                        localeNotifier.value = Locale(newLang);
                      }
                    },
                  ),
                ),
                
                SwitchListTile(
                  title: Text(l10n.soundEffects),
                  subtitle: Text(l10n.soundDesc),
                  value: _isSoundEnabled,
                  activeColor: Colors.blueAccent,
                  secondary: const Icon(Icons.volume_up_rounded, color: Colors.blueAccent),
                  onChanged: (bool value) async {
                    await FeedbackService.setSoundEnabled(value);
                    setState(() {
                      _isSoundEnabled = value;
                    });
                    if (value) FeedbackService.playClickSound();
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.vibrations),
                  subtitle: Text(l10n.vibrationDesc),
                  value: _isVibrationEnabled,
                  activeColor: Colors.blueAccent,
                  secondary: const Icon(Icons.vibration_rounded, color: Colors.blueAccent),
                  onChanged: (bool value) async {
                    await FeedbackService.setVibrationEnabled(value);
                    setState(() {
                      _isVibrationEnabled = value;
                    });
                    if (value) FeedbackService.playScanVibration();
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.dailyReminder),
                  subtitle: Text(l10n.dailyReminderDesc),
                  value: _isDailyReminderEnabled,
                  activeColor: Colors.blueAccent,
                  secondary: const Icon(Icons.notifications_active_rounded, color: Colors.blueAccent),
                  onChanged: (bool value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_daily_reminder', value);
                    final pushService = PushNotificationService();
                    if (value) {
                      await pushService.scheduleDailyReminder(hour: 20, minute: 0);
                    } else {
                      await pushService.cancelDailyReminder();
                    }
                    setState(() {
                      _isDailyReminderEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.saveChanges, 
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}

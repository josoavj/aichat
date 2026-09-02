import 'package:ai_test/pages/firebase_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../others/app_theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Déclarations pour les nouveaux paramètres
  double _currentFontSize = 1.0;
  bool _hapticFeedbackEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Charge les paramètres utilisateur depuis le ThemeNotifier
  void _loadSettings() {
    final themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
    setState(() {
      _currentFontSize = themeProvider.fontSize;
      _hapticFeedbackEnabled = themeProvider.hapticFeedbackEnabled;
    });
  }

  // Sauvegarde les paramètres utilisateur via le ThemeNotifier
  void _saveSettings() async {
    final themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
    await themeProvider.setFontSizeAsync(_currentFontSize);
    await themeProvider.setHapticFeedbackAsync(_hapticFeedbackEnabled);
  }

  // Fonction pour afficher le dialogue de sélection de couleur
  void showColorPickerDialog() {
    Color pickerColor =
        Provider.of<ThemeNotifier>(context, listen: false).primarySwatch;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Choisir une couleur', style: GoogleFonts.poppins()),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    setState(() => pickerColor = color);
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsvWithHue,
                  labelTypes: const [],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ThemeNotifier>(context, listen: false)
                        .changeThemeColor(pickerColor);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Appliquer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Fonction pour afficher le dialogue de changement de clé API
  void showApiKeyDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('gemini_api_key') ?? '';
    final TextEditingController keyController =
        TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Changer de clé API', style: GoogleFonts.poppins()),
          content: TextField(
            controller: keyController,
            decoration: InputDecoration(
              hintText: 'Entrez votre nouvelle clé API',
              hintStyle: GoogleFonts.poppins(),
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (keyController.text.isNotEmpty) {
                  await prefs.setString('gemini_api_key', keyController.text);
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Clé API mise à jour.',
                              style: GoogleFonts.poppins())),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction de déconnexion
  void _handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FirebaseLoginPage()),
    );
  }

  // Fonction pour effacer l'historique du chat
  void _clearChatHistory() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Effacer l\'historique?', style: GoogleFonts.poppins()),
          content: Text(
              'Êtes-vous sûr de vouloir effacer toutes les conversations?',
              style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(
                    'chat_history'); // Supprime l'historique (clé fictive)
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Historique effacé.',
                            style: GoogleFonts.poppins())),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionHeader("Apparence"),
          _buildSettingCard([
            ListTile(
              leading: _buildIcon(Icons.palette_outlined, theme.primaryColor),
              title: Text('Couleur du Thème', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: themeProvider.primarySwatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
              onTap: showColorPickerDialog,
            ),
            const Divider(indent: 56),
            SwitchListTile(
              secondary: _buildIcon(isDark ? Icons.dark_mode : Icons.light_mode, theme.primaryColor),
              title: Text('Mode Sombre', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (bool value) => themeProvider.toggleThemeMode(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader("Interface"),
          _buildSettingCard([
            ListTile(
              leading: _buildIcon(Icons.text_fields, theme.primaryColor),
              title: Text('Taille du texte', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Slider(
                value: _currentFontSize,
                min: 0.8,
                max: 1.2,
                divisions: 4,
                onChanged: (value) {
                  setState(() => _currentFontSize = value);
                  _saveSettings();
                },
              ),
            ),
            const Divider(indent: 56),
            SwitchListTile(
              secondary: _buildIcon(Icons.vibration, theme.primaryColor),
              title: Text('Retour haptique', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              value: _hapticFeedbackEnabled,
              onChanged: (bool value) {
                setState(() => _hapticFeedbackEnabled = value);
                _saveSettings();
                if (value) HapticFeedback.selectionClick();
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader("Sécurité & Données"),
          _buildSettingCard([
            ListTile(
              leading: _buildIcon(Icons.key_outlined, theme.primaryColor),
              title: Text('Clé API Gemini', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Configurer votre accès à l\'IA', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              onTap: showApiKeyDialog,
            ),
            const Divider(indent: 56),
            ListTile(
              leading: _buildIcon(Icons.delete_outline, Colors.redAccent),
              title: Text('Effacer l\'historique', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              onTap: _clearChatHistory,
            ),
          ]),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text("Déconnexion"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

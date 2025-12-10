import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clés pour SharedPreferences
class PreferencesKeys {
  static const String themeMode = 'themeMode';
  static const String primaryColorValue = 'primaryColorValue';
  static const String fontSize = 'font_size';
  static const String hapticFeedback = 'haptic_feedback_enabled';
}

/// Gère l'état du thème de l'application (mode et couleur).
/// Il étend ChangeNotifier pour notifier ses auditeurs des changements.
class ThemeNotifier with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeMode _currentThemeMode = ThemeMode.dark;
  MaterialColor _primarySwatch = Colors.blue;

  ThemeMode get themeMode => _currentThemeMode;
  MaterialColor get primarySwatch => _primarySwatch;
  double get fontSize => _fontSize;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get isInitialized => _isInitialized;

  double _fontSize = 1.0;
  bool _hapticFeedbackEnabled = true;

  ThemeNotifier() {
    _initializePreferences();
  }

  /// Initialise SharedPreferences de manière synchrone pour le démarrage
  /// À appeler dans main() avant de démarrer l'app
  Future<void> initializeSync() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemeSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'initialisation des préférences: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Initialise SharedPreferences de manière asynchrone au démarrage
  Future<void> _initializePreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemeSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'initialisation des préférences: $e');
    }
  }

  /// Charge les paramètres du thème depuis SharedPreferences
  Future<void> _loadThemeSettings() async {
    try {
      final colorValue = _prefs.getInt(PreferencesKeys.primaryColorValue);
      if (colorValue != null) {
        _primarySwatch = AppThemes.createMaterialColor(Color(colorValue));
      }
      final themeModeIndex = _prefs.getInt(PreferencesKeys.themeMode);
      if (themeModeIndex != null) {
        _currentThemeMode = ThemeMode.values[themeModeIndex];
      }
      final fontSize = _prefs.getDouble(PreferencesKeys.fontSize);
      if (fontSize != null) {
        _fontSize = fontSize;
      }
      final hapticFeedback = _prefs.getBool(PreferencesKeys.hapticFeedback);
      if (hapticFeedback != null) {
        _hapticFeedbackEnabled = hapticFeedback;
      }
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  /// Bascule entre le mode clair et le mode sombre
  Future<void> toggleThemeMode() async {
    if (!_isInitialized) return;
    try {
      _currentThemeMode = _currentThemeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      await _prefs.setInt(PreferencesKeys.themeMode, _currentThemeMode.index);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du changement de mode de thème: $e');
    }
  }

  /// Change la couleur primaire du thème
  Future<void> changeThemeColor(Color newColor) async {
    if (!_isInitialized) return;
    try {
      _primarySwatch = AppThemes.createMaterialColor(newColor);
      await _prefs.setInt(PreferencesKeys.primaryColorValue, newColor.value);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du changement de couleur: $e');
    }
  }

  /// Met à jour la taille de police
  Future<void> setFontSizeAsync(double newSize) async {
    if (!_isInitialized) return;
    try {
      _fontSize = newSize;
      await _prefs.setDouble(PreferencesKeys.fontSize, newSize);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour de la taille de police: $e');
    }
  }

  /// Met à jour l'état du retour haptique
  Future<void> setHapticFeedbackAsync(bool enabled) async {
    if (!_isInitialized) return;
    try {
      _hapticFeedbackEnabled = enabled;
      await _prefs.setBool(PreferencesKeys.hapticFeedback, enabled);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour du retour haptique: $e');
    }
  }
}

/// Contient les définitions complètes des thèmes (clair et sombre).
class AppThemes {
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;
    for (int i = 0; i < 10; i++) {
      swatch[(strengths[i] * 1000).round()] =
          Color.fromRGBO(r, g, b, strengths[i]);
    }
    return MaterialColor(color.value, swatch);
  }

  static ThemeData lightTheme(MaterialColor primarySwatch) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySwatch,
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black,
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySwatch,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch[300]!),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        labelStyle: GoogleFonts.poppins(color: Colors.black87),
      ),
    );
  }

  static ThemeData darkTheme(MaterialColor primarySwatch) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primarySwatch,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: AppBarTheme(
        backgroundColor: primarySwatch[700],
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white70,
              displayColor: Colors.white,
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySwatch,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch[300]!, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primarySwatch[600]!),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
      ),
    );
  }
}

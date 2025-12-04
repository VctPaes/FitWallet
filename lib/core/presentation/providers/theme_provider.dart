import 'package:flutter/material.dart';
import '../../services/prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PrefsService prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required this.prefs});

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Carrega o tema salvo ao iniciar o app
  void loadTheme() {
    final savedMode = prefs.getThemeMode();
    _themeMode = _stringToThemeMode(savedMode);
    notifyListeners();
  }

  /// Alterna o tema (chamado pelo Switch)
  Future<void> updateThemeMode(ThemeMode newMode) async {
    if (_themeMode != newMode) {
      _themeMode = newMode;
      await prefs.setThemeMode(_themeModeToString(newMode));
      notifyListeners();
    }
  }

  // Auxiliares de Conversão
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'system';
    }
  }
}
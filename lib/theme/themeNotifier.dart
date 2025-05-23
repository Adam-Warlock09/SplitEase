import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _themeKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() async {

    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeKey);
    if (mode == 'light') {
      _themeMode = ThemeMode.dark;
    }
    else if (mode == 'dark') {
      _themeMode = ThemeMode.light;
    }
    await prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();

  }

  Future<void> loadTheme() async {

    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeKey);
    if (mode != null) {
      _themeMode = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    } else {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.light : ThemeMode.dark;
      await prefs.setString(_themeKey, _themeMode.name);
      notifyListeners();
    }

  }
}

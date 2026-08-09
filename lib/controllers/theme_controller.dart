import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/constants.dart';

/// Controller: holds the app theme mode (V1.0 需求 6.4 深色模式).
class ThemeController extends ChangeNotifier {
  static const String _storageKey = 'todolist.theme.v1';

  AppThemeMode _mode = AppThemeMode.light;

  AppThemeMode get mode => _mode;

  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_storageKey);
    if (index != null && index >= 0 && index < AppThemeMode.values.length) {
      _mode = AppThemeMode.values[index];
      notifyListeners();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, mode.index);
  }
}

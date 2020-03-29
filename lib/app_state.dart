import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  AppState(this.themeMode);

  void updateTheme(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

// selector de tema claro/oscuro global
class ThemeController extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
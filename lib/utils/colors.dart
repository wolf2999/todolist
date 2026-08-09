import 'package:flutter/material.dart';

/// Shared color palette used across views (MVC: consumed by the View layer).
/// Colors are matched 1:1 to the design spec (UI 界面图).
class ToDoColors {
  // Home screen (UI1) — blue gradient header
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryDark = Color(0xFF3B5BDB);
  static const Color primaryLight = Color(0xFF6D8BFF);

  // Edit task screen (UI2) — purple gradient header
  static const Color editPrimary = Color(0xFF7B6CF6);
  static const Color editPrimaryDark = Color(0xFF6A5AE0);

  // Generic surfaces
  static const Color background = Color(0xFFF4F6FB);
  static const Color card = Colors.white;
  static const Color grey = Color(0xFFF0F2F7);

  static const Color textDark = Color(0xFF222B45);
  static const Color textGrey = Color(0xFF8C96A8);
  static const Color divider = Color(0xFFEDEFF4);

  // Priority colors (V1.1)
  static const Color priorityHigh = Color(0xFFF25F5C);
  static const Color priorityMedium = Color(0xFFF5A623);
  static const Color priorityLow = Color(0xFF4CAF85);

  // Extra accent used in category screen (UI3)
  static const Color categoryBg = Color(0xFFEDF1FB);
  static const Color categoryHeader = Color(0xFF5A6CF0);

  static const Color warning = Color(0xFFF25F5C);
}

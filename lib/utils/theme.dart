import 'package:flutter/material.dart';

import 'colors.dart';

/// Builds the [ThemeData] used by the app, matching the UI design.
ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: ToDoColors.primary,
    fontFamily: 'Rubik',
    scaffoldBackgroundColor: ToDoColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ToDoColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

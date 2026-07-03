import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.deepPurple[50],
      extensions: const [
        AppColorsExtension(background: Colors.white)
      ]
    );
  }

  static ThemeData get amoled {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      extensions: const [
        AppColorsExtension(background: Color.fromARGB(255, 0, 0, 0))
      ]
    );
  }
}
import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      extensions: const [
        AppColorsExtension(leaveDeleteColor: Colors.red)
      ],
    );
  }

  static ThemeData get amoled {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      extensions: [
        AppColorsExtension(leaveDeleteColor: Colors.red.shade400)
      ]
    );
  }
}
import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      extensions: const [
        AppColorsExtension(leaveDeleteColor: Colors.red, halfOpaqueText: Colors.black38, defaultButtonColor: Colors.deepPurple, dateDividerBg: Colors.black12)
      ],
    );
  }

  static ThemeData get amoled {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      extensions: [
        AppColorsExtension(leaveDeleteColor: Colors.red.shade400, halfOpaqueText: Colors.white38, defaultButtonColor: Colors.deepPurpleAccent, dateDividerBg: Colors.white12)
      ]
    );
  }
}
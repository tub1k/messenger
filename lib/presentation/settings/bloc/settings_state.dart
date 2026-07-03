part of "settings_bloc.dart";

class SettingsState {
  final Locale locale;
  final Map<String, dynamic> otherSettings;
  final Map<String, dynamic>? navigateToData;

  ThemeData get themeData {
    final themeSetting = otherSettings['theme'] as AppThemeSetting;
    switch (themeSetting) {
      case AppThemeSetting.system:
        final brightness = PlatformDispatcher.instance.platformBrightness;
        if (brightness == Brightness.light) {
          return AppTheme.light;
        } else {return AppTheme.amoled;}
      case AppThemeSetting.light:
        return AppTheme.light;
      case AppThemeSetting.amoled:
        return AppTheme.amoled;
    }
  }

  SettingsState({required this.locale, this.navigateToData, required this.otherSettings}); }

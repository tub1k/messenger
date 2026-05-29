import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;
  
  SettingsRepository(this._prefs);

  static const _langKey = 'language_code';

  String getLanguageCode() {
    if (_prefs.getString(_langKey) == 'system') {
      return PlatformDispatcher.instance.locale.languageCode;
    } 
    return _prefs.getString(_langKey) ?? PlatformDispatcher.instance.locale.languageCode;
  }

  Future<void> saveLanguage(String code) => _prefs.setString(_langKey, code);
}
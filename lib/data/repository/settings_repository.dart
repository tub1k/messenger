import 'dart:convert';
import 'dart:ui';

import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const _langKey = 'language_code';
  static const _setKey = 'settings'; // other settings key

  String getLanguageCode() {
    if (_prefs.getString(_langKey) == 'system') {
      return PlatformDispatcher.instance.locale.languageCode;
    }
    return _prefs.getString(_langKey) ??
        PlatformDispatcher.instance.locale.languageCode;
  }

  Map<String, dynamic> getOtherSettings() {
    final settingsJson = _prefs.getString(_setKey);
    final Map<String, dynamic>? settings;
    // converting what we got from prefs to map or null
    if (settingsJson != null) {
      settings = jsonDecode(settingsJson);
    } else {
      settings = null;
    }
    // default settings that we return if we got null from prefs
    final Map<String, dynamic> defaultSettings = {
      'theme': AppThemeSetting.system,
    };
    // converting strings back to enums because we like enums
    final returnSettings = (settings != null && settings['theme'] is String)
        ? {
            ...settings,
            'theme': () {
              try {
                return AppThemeSetting.values.byName(settings!['theme']);
              } catch (_) {
                return AppThemeSetting.system;
              }
            } (),
          }
        : defaultSettings;
    return returnSettings;
  }

  Future<void> saveLanguage(String code) => _prefs.setString(_langKey, code);
  Future<void> saveOtherSettings(Map<String, dynamic> map) {
    // converting enums to strings as prefs/json cant have a map with enums
    final Map<String, dynamic> noenumMap = {
      ...map,
      'theme': (map['theme'] as AppThemeSetting).name,
    };
    return _prefs.setString(_setKey, jsonEncode(noenumMap));
  }
}

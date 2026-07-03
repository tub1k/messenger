import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/settings_repository.dart';
import 'package:messenger/presentation/core/themes/app_theme.dart';

part "settings_event.dart";
part "settings_state.dart";

enum AppThemeSetting {
  system,
  light,
  amoled
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;
  SettingsBloc(this.settingsRepository)
    : super(
        SettingsState(locale: Locale(settingsRepository.getLanguageCode()), otherSettings: settingsRepository.getOtherSettings()),
      ) {
    on<SettingsSetLocale>((event, emit) async {
      await settingsRepository.saveLanguage(event.localeCode);
      emit(SettingsState(locale: _resolveLocale(event.localeCode), navigateToData: state.navigateToData, otherSettings: state.otherSettings)); 
    }); 

    on<SettingsSetTheme>((event, emit) async {
      final newSettings = {...state.otherSettings, 'theme': event.themeSetting};
      await settingsRepository.saveOtherSettings(newSettings);
      emit(SettingsState(locale: state.locale, otherSettings: newSettings));
    });
    
    on<SettingsPushScreen>((event, emit) {
      emit(SettingsState(locale: state.locale, navigateToData: event.data, otherSettings: state.otherSettings)); 
    });

    on<SettingsResetNavigation>((event, emit) {
      emit(SettingsState(locale: state.locale, navigateToData: null, otherSettings: state.otherSettings));
    }); 
  }

  static Locale _resolveLocale(String code) {
    if (code == 'system') {
      return Locale(PlatformDispatcher.instance.locale.languageCode);
    }
    return Locale(code);
  }
}

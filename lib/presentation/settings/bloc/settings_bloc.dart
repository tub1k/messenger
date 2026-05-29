import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/settings_repository.dart';

part "settings_event.dart";
part "settings_state.dart";

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;
  SettingsBloc(this.settingsRepository)
    : super(
        SettingsState(locale: Locale(settingsRepository.getLanguageCode())),
      ) {
    on<SettingsSetLocale>((event, emit) async {
      await settingsRepository.saveLanguage(event.localeCode);
      emit(SettingsState(locale: _resolveLocale(event.localeCode))); // TODO: maybe make it say system in setting menu when language is not set
    }); 
  }

  static Locale _resolveLocale(String code) {
    if (code == 'system') {
      return Locale(PlatformDispatcher.instance.locale.languageCode);
    }
    return Locale(code);
  }
}

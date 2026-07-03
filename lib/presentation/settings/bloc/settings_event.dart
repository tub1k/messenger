part of "settings_bloc.dart";

class SettingsEvent {}

class SettingsSetLocale extends SettingsEvent {
  final String localeCode;

  SettingsSetLocale({required this.localeCode});
}

class SettingsSetTheme extends SettingsEvent {
  final AppThemeSetting themeSetting;

  SettingsSetTheme({required this.themeSetting});
}

class SettingsPushScreen extends SettingsEvent {
  final Map<String, dynamic> data;

  SettingsPushScreen({required this.data});
}

class SettingsResetNavigation extends SettingsEvent {}
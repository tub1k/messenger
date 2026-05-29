part of "settings_bloc.dart";

class SettingsEvent {}

class SettingsSetLocale extends SettingsEvent {
  final String localeCode;

  SettingsSetLocale({required this.localeCode});
}
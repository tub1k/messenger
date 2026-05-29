// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get auraMessenger => 'Aura messenger';

  @override
  String get newChat => 'New Chat';

  @override
  String get addUserToChatHint => 'Enter users tags to add them to chat';

  @override
  String get confirm => 'confirm';

  @override
  String get failedToGetUser => 'Failed to get user';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemLang => 'System language';
}

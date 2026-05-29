// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get auraMessenger => 'Aura мессенджер';

  @override
  String get newChat => 'New Chat';

  @override
  String get addUserToChatHint => 'Enter users tags to add them to chat';

  @override
  String get confirm => 'confirm';

  @override
  String get failedToGetUser => 'Failed to get user';
}

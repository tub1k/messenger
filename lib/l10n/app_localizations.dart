import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @auraMessenger.
  ///
  /// In en, this message translates to:
  /// **'Aura messenger'**
  String get auraMessenger;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @addUserToChatHint.
  ///
  /// In en, this message translates to:
  /// **'Enter users tags to add them to chat'**
  String get addUserToChatHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get confirm;

  /// No description provided for @failedToGetUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to get user'**
  String get failedToGetUser;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLang.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLang;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @addSomeoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Add someone first!'**
  String get addSomeoneFirst;

  /// No description provided for @chatName.
  ///
  /// In en, this message translates to:
  /// **'Chat Name'**
  String get chatName;

  /// No description provided for @addChatPicture.
  ///
  /// In en, this message translates to:
  /// **'Add chat picture'**
  String get addChatPicture;

  /// No description provided for @createChat.
  ///
  /// In en, this message translates to:
  /// **'Create chat!'**
  String get createChat;

  /// No description provided for @failedToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// No description provided for @unknownLoadingChatsError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error has happened while loading chats :('**
  String get unknownLoadingChatsError;

  /// No description provided for @updateToSeeThisMessageType.
  ///
  /// In en, this message translates to:
  /// **'Update the app to see this message type'**
  String get updateToSeeThisMessageType;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @chatNameHint.
  ///
  /// In en, this message translates to:
  /// **'My Chat'**
  String get chatNameHint;

  /// No description provided for @failedToCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat'**
  String get failedToCreateChat;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error! Check your internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Content not found.'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session timed out. Please re-login.'**
  String get errorUnauthorized;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @triedToAddUserOnWrongScreen.
  ///
  /// In en, this message translates to:
  /// **'Tried to add user while on wrong screen'**
  String get triedToAddUserOnWrongScreen;

  /// No description provided for @cantAddYourself.
  ///
  /// In en, this message translates to:
  /// **'you cant add yourself!'**
  String get cantAddYourself;

  /// No description provided for @galleryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission denied.'**
  String get galleryPermissionDenied;

  /// No description provided for @loadingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image downloaded successfully!'**
  String get loadingSuccess;

  /// No description provided for @loadingStarted.
  ///
  /// In en, this message translates to:
  /// **'Started image download...'**
  String get loadingStarted;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String members(num count);

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'last seen'**
  String get lastSeen;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

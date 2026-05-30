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
  String get newChat => 'Новый Чат';

  @override
  String get addUserToChatHint =>
      'впиши юзернейм человека для добавления в чат...';

  @override
  String get confirm => 'подтвердить';

  @override
  String get failedToGetUser => 'Не удалочь получить пользователя';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get systemLang => 'Язык системы';

  @override
  String get chats => 'Чаты';

  @override
  String get addSomeoneFirst => 'Сначала добавь участников!';

  @override
  String get chatName => 'Название чата';

  @override
  String get addChatPicture => 'Добавь картинку чата';

  @override
  String get createChat => 'Создать чат!';

  @override
  String get failedToLoadChats => 'Не удалось загрузить чаты';

  @override
  String get unknownLoadingChatsError =>
      'Неизестная ошибка произошла во время загрузки чатов :(';

  @override
  String get updateToSeeThisMessageType =>
      'Обновите приложение, чтобы увидеть этот тип сообщений';

  @override
  String get error => 'Ошибка';
}

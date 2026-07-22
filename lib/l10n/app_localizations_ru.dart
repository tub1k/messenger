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

  @override
  String get chatNameHint => 'Мой чат';

  @override
  String get failedToCreateChat => 'Ошибка при создании чата';

  @override
  String get errorNetwork => 'Ошибка сети! Проверьте своё интернет соединение.';

  @override
  String get errorNotFound => 'Контент не найден.';

  @override
  String get errorUnauthorized => 'Сессия устарела. Войдите заново';

  @override
  String get errorUnknown => 'Что-то пошло не так.';

  @override
  String get triedToAddUserOnWrongScreen =>
      'Попытка добавить пользователя на неправильном экране';

  @override
  String get cantAddYourself => 'Нельзя добавить самого себя!';

  @override
  String get galleryPermissionDenied =>
      'Нет разрешения на сохранение в галерею';

  @override
  String get loadingSuccess => 'Фото успешно сохранено!';

  @override
  String get loadingStarted => 'Начали загрузку изображения...';

  @override
  String members(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'был в сети';

  @override
  String get online => 'онлайн';

  @override
  String get userInList => 'Пользователь уже в списке';

  @override
  String get mute => 'Заглушить';

  @override
  String get unmute => 'Оповещать';

  @override
  String get leave => 'Выйти';

  @override
  String get invite => 'Пригласить';

  @override
  String get systemTheme => 'Тема системы';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get amoledTheme => 'AMOLED-тема';

  @override
  String get theme => 'Тема';

  @override
  String get addFriend => 'Добавить в друзья';

  @override
  String get writeDM => 'Написать сообщение';

  @override
  String get aboutMe => 'Обо мне';

  @override
  String get removeFriend => 'Удалить друга';

  @override
  String get cancelInvite => 'Отменить заявку';

  @override
  String get acceptInvite => 'Принять в друзья';

  @override
  String get invalidRequest => 'Эта заявка в друзья не валидна';
}

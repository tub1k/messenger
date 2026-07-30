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

  @override
  String get chats => 'Chats';

  @override
  String get addSomeoneFirst => 'Add someone first!';

  @override
  String get chatName => 'Chat Name';

  @override
  String get addChatPicture => 'Add chat picture';

  @override
  String get createChat => 'Create chat!';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get unknownLoadingChatsError => 'Unknown error has happened while loading chats :(';

  @override
  String get updateToSeeThisMessageType => 'Update the app to see this message type';

  @override
  String get error => 'Error';

  @override
  String get chatNameHint => 'My Chat';

  @override
  String get failedToCreateChat => 'Failed to create chat';

  @override
  String get errorNetwork => 'Network error! Check your internet connection.';

  @override
  String get errorNotFound => 'Content not found.';

  @override
  String get errorUnauthorized => 'Session timed out. Please re-login.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get triedToAddUserOnWrongScreen => 'Tried to add user while on wrong screen';

  @override
  String get cantAddYourself => 'you cant add yourself!';

  @override
  String get galleryPermissionDenied => 'Gallery permission denied.';

  @override
  String get loadingSuccess => 'Image downloaded successfully!';

  @override
  String get loadingStarted => 'Started image download...';

  @override
  String members(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      few: '$count members',
      one: '$count member',
    );
    return '$_temp0';
  }

  @override
  String get lastSeen => 'last seen';

  @override
  String get online => 'online';

  @override
  String get userInList => 'User is already in the list';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get leave => 'Leave';

  @override
  String get invite => 'Invite';

  @override
  String get systemTheme => 'System theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get amoledTheme => 'AMOLED theme';

  @override
  String get theme => 'Theme';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get writeDM => 'Send a message';

  @override
  String get aboutMe => 'About me';

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String get cancelInvite => 'Cancel invite';

  @override
  String get acceptInvite => 'Accept invite';

  @override
  String get invalidRequest => 'This friend request is invalid';

  @override
  String get friends => 'Friends';

  @override
  String get incomingInvites => 'Incoming Invites';

  @override
  String get outgoingInvites => 'Outgoing Invites';

  @override
  String get noFriendsYet => 'You have no friends yet, add them using search bar above!';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get today => 'Today';
}

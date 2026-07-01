import 'package:flutter/material.dart';
import 'package:messenger/l10n/app_localizations.dart';

enum AppErrorType {
  network,
  notFound,
  unauthorized,
  unknown,
  failedToCreateChat,
  addSomeoneFirst,
  triedToAddUserOnWrongScreen,
  cantAddYourself,
  galleryPermissionDenied,
  userInList,
}

class ErrorHandler {
  static AppErrorType from(Object error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('SocketException') || errorStr.contains('Network')) {
      return AppErrorType.network;
    }
    if (errorStr.contains('404')) {
      return AppErrorType.notFound;
    }
    if (errorStr.contains('401') || errorStr.contains('Token expired')) {
      return AppErrorType.unauthorized;
    }
    if (errorStr.contains('failed_to_create_chat'))  {
      return AppErrorType.failedToCreateChat;
    }
    if (errorStr.contains('add_someone_first')) {
      return AppErrorType.addSomeoneFirst;
    }
    if (errorStr.contains('triedToAddUserOnWrongScreen')) {
      return AppErrorType.triedToAddUserOnWrongScreen;
    }
    if (errorStr.contains('cantAddYourself')) {
      return AppErrorType.cantAddYourself;
    }
    if (errorStr.contains('galleryPermissionDenied')) {
      return AppErrorType.galleryPermissionDenied;
    }
    if (errorStr.contains('user_in_list')) {
      return AppErrorType.userInList;
    }
    
    return AppErrorType.unknown;
  }
}

extension AppErrorLocalization on AppErrorType {
  String localizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    switch (this) {
      case AppErrorType.network:
        return l10n!.errorNetwork; 
      case AppErrorType.notFound:
        return l10n!.errorNotFound;
      case AppErrorType.unauthorized:
        return l10n!.errorUnauthorized;
      case AppErrorType.failedToCreateChat:
        return l10n!.failedToCreateChat;
      case AppErrorType.addSomeoneFirst:
        return l10n!.addSomeoneFirst;
      case AppErrorType.triedToAddUserOnWrongScreen:
        return l10n!.triedToAddUserOnWrongScreen;
      case AppErrorType.cantAddYourself:
        return l10n!.cantAddYourself;
      case AppErrorType.galleryPermissionDenied:
        return l10n!.galleryPermissionDenied;
      case AppErrorType.unknown:
        return l10n!.errorUnknown;
      case AppErrorType.userInList:
        return l10n!.userInList;
    }
  }
}
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
  invalidRequest,
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
    if (errorStr.contains('invalid_request')) {
      return AppErrorType.invalidRequest;
    }
    
    return AppErrorType.unknown;
  }
}

extension AppErrorLocalization on AppErrorType {
  String localizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return switch (this) {
      AppErrorType.network => l10n.errorNetwork,
      AppErrorType.notFound => l10n.errorNotFound,
      AppErrorType.unauthorized => l10n.errorUnauthorized,
      AppErrorType.failedToCreateChat => l10n.failedToCreateChat,
      AppErrorType.addSomeoneFirst => l10n.addSomeoneFirst,
      AppErrorType.triedToAddUserOnWrongScreen => l10n.triedToAddUserOnWrongScreen,
      AppErrorType.cantAddYourself => l10n.cantAddYourself,
      AppErrorType.galleryPermissionDenied => l10n.galleryPermissionDenied,
      AppErrorType.unknown => l10n.errorUnknown,
      AppErrorType.userInList => l10n.userInList,
      AppErrorType.invalidRequest => l10n.invalidRequest,
    };
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/l10n/app_localizations.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/core/themes/app_theme_extension.dart';

extension AuthExtensionX on BuildContext {

  /// if used after user is authorised, returns his UID, otherwise null
  String? get myId {
    final curState = read<AuthBloc>().state;
    if (curState is AuthSuccess) return curState.userId;
    return null;
  } 
}

extension AppLocalizationsX on BuildContext {
  /// get localizations
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}



extension ChatDateTimeX on DateTime {
  String toMessageTime() {
    return DateFormat('HH:mm').format(this);
  }

  String toChatListTime(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(year, month, day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(this);
    } else if (messageDate == yesterday) {
      return l10n.yesterday; 
    } else if (now.difference(messageDate).inDays < 7) {
      final dayName = DateFormat('E', locale).format(this);
      return dayName[0].toUpperCase() + dayName.substring(1);
    } else if (year == now.year) {
      return DateFormat('d MMM', locale).format(this);
    } else {
      return DateFormat('dd.MM.yy').format(this); 
    }
  }

  String toDateDivider(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(year, month, day);

    if (messageDate == today) {
      return l10n.today;
    } else if (messageDate == yesterday) {
      return l10n.yesterday;
    } else if (year == now.year) {
      return DateFormat('d MMMM', locale).format(this); 
    } else {
      return DateFormat('d MMMM yyyy', locale).format(this);
    }
  }

  String toFullDateTime(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(year, month, day);

    final time = DateFormat('HH:mm').format(this);
    
    final at = locale.startsWith('ru') ? 'в' : 'at';

    if (messageDate == today) {
      return '${l10n.today} $at $time';
    } else if (messageDate == yesterday) {
      return '${l10n.yesterday} $at $time';
    } else if (year == now.year) {
      final date = DateFormat('d MMMM', locale).format(this);
      return '$date $at $time';
    } else {
      final date = DateFormat('dd.MM.yy', locale).format(this);
      return '$date $at $time';
    }
  }
}
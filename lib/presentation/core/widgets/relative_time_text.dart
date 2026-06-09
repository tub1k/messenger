import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:messenger/l10n/app_localizations.dart';

class RelativeTimeText extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;
  final bool? isShort;
  const RelativeTimeText({
    super.key,
    required this.dateTime,
    this.style,
    this.isShort,
  });

  @override
  Widget build(BuildContext context) {
    final String currentLanguageCode =
        AppLocalizations.of(context)!.localeName +
        ((isShort ?? false) ? '_short' : '');
    final relativeTime = timeago.format(dateTime, locale: currentLanguageCode);
    return Text(relativeTime, style: style ?? TextStyle(fontSize: 12));
  }
}

import 'package:flutter/material.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/server_time_offset.dart';
import 'package:messenger/presentation/core/widgets/relative_time_text.dart';

class DetailedLastSeenWidget extends StatelessWidget {
  const DetailedLastSeenWidget({
    super.key,
    required this.userModel,
    required this.context,
    this.subtitleStyle,
  });

  final BaseUserModel? userModel;
  final BuildContext context;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final user = userModel; // for promotion
    if (user == null) {
      return SizedBox();
    } else if (user.isOnline == true &&
        trueCurrentTime.difference(user.lastSeen) < Duration(minutes: 3)) {
      return Row(
        children: [
          Text(
            context.l10n.online,
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text('${context.l10n.lastSeen} ', style: subtitleStyle),
          RelativeTimeText(dateTime: user.lastSeen, style: subtitleStyle),
        ],
      );
    }
  }
}

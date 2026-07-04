import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/presentation/chat/custom_icon_button.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/widgets/detailed_last_seen_widget.dart';

class ProfileContent extends StatelessWidget {
  final BaseUserModel user;
  const ProfileContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: user.photoUrl.length > 2
                    ? FastCachedImageProvider(user.photoUrl)
                    : null,
                child:
                    (user.photoUrl.length <= 2) && (user.displayName.isNotEmpty)
                    ? Text(
                        user.displayName[0].toUpperCase(),
                        style: TextStyle(fontSize: 50),
                      )
                    : null,
              ),
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName, style: TextStyle(fontSize: 28)),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: context.colors.halfOpaqueText,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  DetailedLastSeenWidget(
                    userModel: user,
                    context: context,
                    subtitleStyle: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButton(
                onTap: () {},
                text: context.l10n.addFriend,
                color: context.colors.defaultButtonColor,
                icon: Icons.person_add_alt_1,
                width: 160,
              ),
              CustomIconButton(
                onTap: () {},
                text: context.l10n.writeDM,
                color: context.colors.defaultButtonColor,
                icon: Icons.chat,
                width: 160,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(context.l10n.aboutMe, style: TextStyle(fontSize: 16))
        ],
      ),
    );
  }
}

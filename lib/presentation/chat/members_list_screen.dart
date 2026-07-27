import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/custom_icon_button.dart';
import 'package:messenger/presentation/chat/gallery_screen.dart';
import 'package:messenger/presentation/profile/bloc/profile_bloc.dart';
import 'package:messenger/presentation/profile/profile_content.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/widgets/detailed_last_seen_widget.dart';

class MembersListScreen extends StatelessWidget {
  final ChatModel chat;
  final ChatBloc chatBloc;
  const MembersListScreen({
    super.key,
    required this.chat,
    required this.chatBloc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent), // for back button
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity, height: 50),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: chatBloc,
                    child: GalleryScreen(
                      imageUrls: [chat.photoUrl],
                      initialIndex: 0,
                      chat: chat,
                    ),
                  ),
                ),
              );
            },
            child: Hero(
              tag: chat.photoUrl,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: chat.photoUrl.length > 2
                    ? FastCachedImageProvider(chat.photoUrl)
                    : null,
                child: chat.photoUrl.length <= 2
                    ? Text(
                        chat.chatName[0].toUpperCase(),
                        style: TextStyle(fontSize: 70),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(chat.chatName, style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconButton(
                text: context.l10n.mute,
                onTap: () {},
                color: Colors.deepPurple,
                icon: Icons.notifications_off_rounded,
              ),
              CustomIconButton(
                text: context.l10n.invite,
                onTap: () {},
                color: Colors.deepPurple,
                icon: Icons.person_add_alt_1,
              ),
              CustomIconButton(
                text: context.l10n.leave,
                onTap: () {},
                color: context.colors.leaveDeleteColor,
                icon: Icons.exit_to_app,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 20),
              Text(
                context.l10n.members(chat.userModels.length),
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemExtent: 50,
              itemCount: chat.userModels.length,
              itemBuilder: (context, index) {
                final user = chat.userModels[index];
                return UserProfileTile(user: user);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileTile extends StatefulWidget {
  const UserProfileTile({super.key, required this.user});

  final BaseUserModel user;

  @override
  State<UserProfileTile> createState() => _UserProfileTileState();
}

class _UserProfileTileState extends State<UserProfileTile> {
  late final Stream<BaseUserModel> _presenceStream;

  @override
  void initState() {
    super.initState();
    _presenceStream = context.read<IChatRepository>().streamUserPresence(
      widget.user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: widget.user,
      stream: _presenceStream,
      builder: (context, asyncSnapshot) {
        final BaseUserModel streamedUser;
        final data = asyncSnapshot.data;
        if (data != null) {
          streamedUser = data;
        } else {
          streamedUser = widget.user;
        }
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return BlocProvider(
                  create: (context) => ProfileBloc(
                    initialUser: streamedUser,
                    chatRepository: context.read<IChatRepository>(),
                    myId: context.myId!,
                  )..add(ProfileSubscribe()),
                  child: ProfileContent(),
                );
              },
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: streamedUser.photoUrl.length > 2
                  ? FastCachedImageProvider(streamedUser.photoUrl)
                  : null,
              child:
                  (streamedUser.photoUrl.length <= 2) &&
                      (streamedUser.displayName.isNotEmpty)
                  ? Text(streamedUser.displayName[0].toUpperCase())
                  : null,
            ),
            title: Text(streamedUser.displayName),
            subtitle: DetailedLastSeenWidget(
              userModel: streamedUser,
              context: context,
            ),
          ),
        );
      },
    );
  }
}

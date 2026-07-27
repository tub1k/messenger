import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/domain/repositories/i_image_repository.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/chat_screen.dart';
import 'package:messenger/presentation/chat/custom_icon_button.dart';
import 'package:messenger/presentation/core/error_handler/error_handler.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/widgets/detailed_last_seen_widget.dart';
import 'package:messenger/presentation/profile/bloc/profile_bloc.dart';
import 'package:messenger/user_relations_bloc.dart';

enum UserRelation { unknown, sentRequest, receivedRequest, friends, blocked }

/// to use in bottom modal sheet!
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final relationsState = context.watch<UserRelationsBloc>().state;
    return BlocConsumer<ProfileBloc, ProfileBlocState>(
      listener: (context, state) {
        if (state.errorText != null) {
          final errorHandler = ErrorHandler.from(state.errorText!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (errorHandler == AppErrorType.unknown)
                    ? state.errorText!
                    : errorHandler.localizedMessage(context),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is ProfilePushChat) {
          final chat = state.chat;
          final currentUserId = context.myId!;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (navContext) => BlocProvider(
                create: (blocContext) => ChatBloc(
                  repository: context.read<IChatRepository>(),
                  storageRepository: context.read<IStorageRepository>(),
                  imageRepository: context.read<IImageRepository>(),
                  myId: currentUserId,
                  chat: chat,
                )..add(ChatStarted(chat.chatId)),
                child: ChatScreen(chat: chat),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final user = state.user;
        final UserRelation userRelation = getUserRelation(relationsState, user);
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
                        (user.photoUrl.length <= 2) &&
                            (user.displayName.isNotEmpty)
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
                  switch (userRelation) {
                    UserRelation.unknown => CustomIconButton(
                      onTap: () {
                        context.read<UserRelationsBloc>().add(RelationsSendInvite(uid: user.uid));
                      },
                      text: context.l10n.addFriend,
                      color: context.colors.defaultButtonColor,
                      icon: Icons.person_add_alt_1,
                      width: 160,
                    ),
                    UserRelation.friends => CustomIconButton(
                      onTap: () {
                        context.read<UserRelationsBloc>().add(RelationsRemoveFriend(uid: user.uid));
                      },
                      text: context.l10n.removeFriend,
                      color: context.colors.defaultButtonColor,
                      icon: Icons.person_remove_alt_1,
                      width: 160,
                    ),
                    UserRelation.sentRequest => CustomIconButton(
                      onTap: () {
                        context.read<UserRelationsBloc>().add(RelationsRecallInvite(uid: user.uid));
                      },
                      text: context.l10n.cancelInvite,
                      color: context.colors.defaultButtonColor,
                      icon: Icons.person_remove_alt_1,
                      width: 160,
                    ),
                    UserRelation.receivedRequest => CustomIconButton(
                      onTap: () {
                        context.read<UserRelationsBloc>().add(RelationsAcceptInvite(uid: user.uid));
                      },
                      text: context.l10n.acceptInvite,
                      color: context.colors.defaultButtonColor,
                      icon: Icons.person_add_alt_1,
                      width: 160,
                    ),
                    UserRelation.blocked => CustomIconButton(
                      onTap: () {
                        // TODO: blocked button functionality
                      },
                      text: context.l10n.addFriend,
                      color: context.colors.defaultButtonColor,
                      icon: Icons.person_add_alt_1,
                      width: 160,
                    ),
                  },
                  CustomIconButton(
                    onTap: () {
                      context.read<ProfileBloc>().add(ProfileSendDM());
                    },
                    text: context.l10n.writeDM,
                    color: context.colors.defaultButtonColor,
                    icon: Icons.chat,
                    width: 160,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(context.l10n.aboutMe, style: TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  UserRelation getUserRelation(
    UserRelationsState relationsState,
    BaseUserModel user,
  ) {
    if (relationsState.incomingInviteIds.contains(user.uid)) {
      return UserRelation.receivedRequest;
    } else if (relationsState.outgoingInviteIds.contains(user.uid)) {
      return UserRelation.sentRequest;
    } else if (relationsState.friendIds.contains(user.uid)) {
      return UserRelation.friends;
    } else if (relationsState.blockedIds.contains(user.uid)) {
      return UserRelation.blocked;
    } else {
      return UserRelation.unknown;
    }
  }
}

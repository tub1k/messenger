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
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/presentation/core/error_handler/error_handler.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/friends_list/friends_list_bloc.dart';
import 'package:messenger/presentation/profile/bloc/profile_bloc.dart';
import 'package:messenger/presentation/profile/profile_content.dart';
import 'package:messenger/user_relations_bloc.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

// because we use it in mainscaffold in pageview
class _FriendsListScreenState extends State<FriendsListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final relationsBloc = context.read<UserRelationsBloc>();

    return BlocProvider(
      create: (context) => FriendsListBloc(
        chatRepository: context.read<IChatRepository>(),
        relationsBloc: relationsBloc,
      )..add(FriendsListInit()),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.friends)),
        body: BlocConsumer<FriendsListBloc, FriendsListState>(
          listener: (context, state) {
            if (state is FriendsListLoaded) {
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
              if (state.chatToPush != null) {
                final chat = state.chatToPush!;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (navContext) => BlocProvider(
                        create: (blocContext) => ChatBloc(
                          repository: context.read<IChatRepository>(),
                          storageRepository: context.read<IStorageRepository>(),
                          imageRepository: context.read<IImageRepository>(),
                          myId: context.myId!,
                          chat: chat,
                          chatListBloc: context.read<ChatListBloc?>(),
                        )..add(ChatStarted(chat.chatId)),
                        child: ChatScreen(chat: chat),
                      ),
                    ),
                  );
              }
            }
          },
          builder: (context, state) {
            if (state is FriendsListLoading) {
              return CircularProgressIndicator();
            }
            if (state is FriendsListLoaded) {
              return CustomScrollView(
                slivers: [
                  if (state.incomingInvites.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          context.l10n.incomingInvites,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: state.incomingInvites.length,
                      itemBuilder: (context, index) {
                        final user = state.incomingInvites[index];
                        return FriendListTile(
                          user: user,
                          type: FriendListTileType.incoming,
                          relationsBloc: relationsBloc,
                          bloc: context.read<FriendsListBloc>(),
                        );
                      },
                    ),
                  ],
                  if (state.outgoingInvites.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          context.l10n.outgoingInvites,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: state.outgoingInvites.length,
                      itemBuilder: (context, index) {
                        final user = state.outgoingInvites[index];
                        return FriendListTile(
                          user: user,
                          type: FriendListTileType.outgoing,
                          relationsBloc: relationsBloc,
                          bloc: context.read<FriendsListBloc>(),
                        );
                      },
                    ),
                  ],
                  if (state.friends.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          context.l10n.friends,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final user = state.friends[index];
                        return FriendListTile(
                          user: user,
                          type: FriendListTileType.friend,
                          relationsBloc: relationsBloc,
                          bloc: context.read<FriendsListBloc>(),
                        );
                      },
                    ),
                  ],
                ],
              );
            } else {
              return Placeholder();
            }
          },
        ),
      ),
    );
  }
}

enum FriendListTileType { friend, incoming, outgoing }

class FriendListTile extends StatelessWidget {
  final BaseUserModel user;
  final FriendListTileType type;
  final UserRelationsBloc relationsBloc;
  final FriendsListBloc bloc;
  const FriendListTile({
    super.key,
    required this.user,
    required this.type,
    required this.relationsBloc,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl.length > 2
            ? FastCachedImageProvider(user.photoUrl)
            : null,
        child: (user.photoUrl.length <= 2) & (user.displayName.isNotEmpty)
            ? Text(user.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(user.displayName),
      subtitle: Text('@${user.username}'),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return BlocProvider(
              create: (context) => ProfileBloc(
                initialUser: user,
                chatRepository: context.read<IChatRepository>(),
                myId: context.myId!,
              )..add(ProfileSubscribe()),
              child: ProfileContent(),
            );
          },
        );
      },
      trailing: switch (type) {
        FriendListTileType.incoming => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconButton(
              onTap: () {
                relationsBloc.add(RelationsAcceptInvite(uid: user.uid));
              },
              text: '',
              color: context.colors.defaultButtonColor,
              icon: Icons.person_add_alt_1,
              width: 80,
              height: 40,
            ),
            SizedBox(width: 10),
            CustomIconButton(
              onTap: () {
                relationsBloc.add(RelationsDeclineInvite(uid: user.uid));
              },
              text: '',
              color: context.colors.leaveDeleteColor,
              icon: Icons.person_remove_alt_1,
              width: 80,
              height: 40,
            ),
          ],
        ),
        FriendListTileType.outgoing => CustomIconButton(
          onTap: () {
            relationsBloc.add(RelationsRecallInvite(uid: user.uid));
          },
          text: '',
          color: context.colors.leaveDeleteColor,
          icon: Icons.cancel,
          width: 80,
          height: 40,
        ),
        FriendListTileType.friend => CustomIconButton(
          onTap: () {
            bloc.add(FriendsListDMButton(myId: context.myId!, uid: user.uid));
          },
          text: '',
          color: context.colors.defaultButtonColor,
          icon: Icons.message,
          width: 80,
          height: 40,
        ),
      },
    );
  }
}

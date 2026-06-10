import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_image_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/chat_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/presentation/core/error_handler/error_handler.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/create_chat/create_chat_sheet.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.auraMessenger)),
      floatingActionButton: IconButton.filled(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.80,
            ),
            builder: (context) {
              return CreateChatSheet();
            },
          );
        },
        icon: Icon(Icons.chat),
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          padding: EdgeInsets.all(16),
        ),
      ),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state is ChatListLoaded) {
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
          }
        },
        builder: (context, state) {
          if (state is ChatListLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is ChatListLoaded) {
            return ListView.builder(
              itemCount: state.chatList.length,
              itemBuilder: (context, index) {
                final ChatModel chat = state.chatList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.photoUrl.length > 2
                        ? NetworkImage(chat.photoUrl)
                        : null,
                    child: chat.photoUrl.length <= 2
                        ? Text(chat.chatName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(chat.chatName),
                  subtitle: Text(chat.lastMessagePreview),
                  onTap: () {
                    final repo = context.read<IChatRepository>();
                    final currentUserId = context.myId!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (navContext) => BlocProvider(
                          create: (blocContext) => ChatBloc(
                            repository: repo,
                            storageRepository: context
                                .read<IStorageRepository>(),
                            imageRepository: context.read<IImageRepository>(),
                            myId: currentUserId,
                            chatId: chat.chatId, // TODO: remove this and rewrite bloc
                            chat: chat,
                          )..add(ChatStarted(chat.chatId)),
                          child: ChatScreen(chat: chat),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatListFailed) {
            return Center(
              child: Text(
                state.errorText ?? context.l10n.unknownLoadingChatsError,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/chat_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('aura messenger')),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state is ChatListLoaded) {
            if (state.errorText != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Failed to load chats")));
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
                  title: Text(chat.chatName),
                  subtitle: Text(chat.lastMessagePreview),
                  onTap: () {
                    final repo = context.read<IChatRepository>();
                    final authState = context.read<AuthBloc>().state;
                    final currentUserId = (authState is AuthSuccess) ? authState.userId : 'unknown';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (navContext) => BlocProvider(
                          create: (blocContext) => ChatBloc(
                            repository: repo,
                            myId: currentUserId,
                            chatId: chat.chatId,
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
                state.errorText ??
                    'Unknown error has happened while loading chats :(',
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}

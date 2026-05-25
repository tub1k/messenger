import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/message_bubble.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondUser = widget.chat.getFirstUserThatIsntUID(context.myId!);
    final hasValidUsername = widget.chat.participants.length == 2 && secondUser?.displayName != null;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            if (hasValidUsername) Text(secondUser!.displayName!) else Text(widget.chat.chatName),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final bool isMe =
                          state.messages[index].senderId ==
                          context.read<ChatBloc>().myId;
                      return MessageBubble(
                        message: state.messages[index],
                        isMe: isMe,
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: TextField(controller: _controller)),
                        Container(
                          decoration: ShapeDecoration(
                            shape: CircleBorder(),
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                context.read<ChatBloc>().add(
                                  ChatMessageSent(
                                    _controller.text,
                                    messageType: MessageType.text,
                                  ),
                                );
                                _controller.clear();
                              }
                            },
                            icon: Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
        listener: (context, state) {},
      ),
    );
  }
}

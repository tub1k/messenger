import 'dart:typed_data';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/core/widgets/detailed_last_seen_widget.dart';
import 'package:messenger/presentation/chat/gallery_screen.dart';
import 'package:messenger/presentation/chat/members_list_screen.dart';
import 'package:messenger/presentation/chat/message_bubble.dart';
import 'package:messenger/presentation/core/error_handler/error_handler.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;
  final _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool isWorthToUpdateTheRead = true;
  String? _lastMessageId;

  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final minScroll = _scrollController.position.minScrollExtent;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 300) {
      context.read<ChatBloc>().add(ChatLoadMoreMessages());
    }

    if (currentScroll <= minScroll + 100 && isWorthToUpdateTheRead) {
      context.read<ChatBloc>().add(ChatUpdateMyReadTime());
      isWorthToUpdateTheRead = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final Widget appBarSubtitle;
    final TextStyle subtitleStyle = TextStyle(fontSize: 16);
    if (chat.participants.length > 2) {
      appBarSubtitle = Text(
        context.l10n.members(chat.participants.length),
        style: subtitleStyle,
      );
    } else if (chat.participants.length == 2) {
      final other = chat.getFirstUserThatIsntUID(context.myId!);
      appBarSubtitle = DetailedLastSeenWidget(
        userModel: other,
        context: context,
        subtitleStyle: subtitleStyle,
      );
    } else {
      appBarSubtitle = SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                final chatBloc = context.read<ChatBloc>();
                if (chat.photoUrl.length <= 2) return;
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
                  backgroundImage: chat.photoUrl.length > 2
                      ? FastCachedImageProvider(chat.photoUrl)
                      : null,
                  child:
                      (chat.photoUrl.length <= 2) & (chat.chatName.isNotEmpty)
                      ? Text(chat.chatName[0].toUpperCase())
                      : null,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final chatBloc = context.read<ChatBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MembersListScreen(chat: chat, chatBloc: chatBloc),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.chat.chatName, overflow: TextOverflow.ellipsis),
                    appBarSubtitle,
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            if (state.messages.isNotEmpty) {
              if (state.messages.first.id != _lastMessageId) {
                isWorthToUpdateTheRead = true;
                _lastMessageId = state.messages.first.id;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return; 

                  if (_scrollController.hasClients && _scrollController.offset <= 100) {
                    context.read<ChatBloc>().add(ChatUpdateMyReadTime());
                    isWorthToUpdateTheRead = false;
                  }
                });
              }
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    cacheExtent: 500,
                    // +1 item if messages are loading to show loader
                    itemCount:
                        state.messages.length + (state.isLoadingMore ? 1 : 0),
                    controller: _scrollController,
                    reverse: true,
                    itemBuilder: (context, index) {
                      // loader if we scrolled to top and more messages are loading
                      if (index == state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      // else message bubbles
                      final message = state.messages[index];
                      final bool isMe =
                          state.messages[index].senderId ==
                          context.read<ChatBloc>().myId;

                      final bool isLastMessage =
                          index == state.messages.length - 1;
                      final bool isNewDay =
                          isLastMessage ||
                          !_isSameDay(
                            message.timestamp,
                            state.messages[index + 1].timestamp,
                          );

                      final messageBubble = MessageBubble(
                        message: state.messages[index],
                        isMe: isMe,
                        chatId: widget.chat.chatId,
                      );

                      if (isNewDay) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _DateDivider(date: message.timestamp),
                            messageBubble,
                          ],
                        );
                      }

                      return messageBubble;
                    },
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      if (state.images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 10,
                            children: state.images.map((image) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  image,
                                  width: 70,
                                  height: 70,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(child: TextField(controller: _controller)),
                            IconButton(
                              onPressed: _showImagePicker,
                              icon: Icon(Icons.attach_file),
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                color: Colors.blue,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  if (_controller.text.trim().isNotEmpty ||
                                      state.images.isNotEmpty) {
                                    final type = state.images.isNotEmpty
                                        ? MessageType.image
                                        : MessageType.text;
                                    context.read<ChatBloc>().add(
                                      ChatMessageSent(
                                        _controller.text,
                                        messageType: type,
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
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
        listener: (context, state) {
          if (state is ChatLoaded) {
            if (state.errorText == 'loading_started') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.loadingStarted),
                  backgroundColor: const Color.fromARGB(255, 50, 169, 238),
                ),
              );
            } else if (state.errorText == 'loading_success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.loadingSuccess),
                  backgroundColor: const Color.fromARGB(255, 50, 238, 106),
                ),
              );
            } else if (state.errorText != null) {
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
      ),
    );
  }

  void _showImagePicker() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
      imageQuality: 65,
      maxWidth: 1200,
      maxHeight: 1200,
      limit: 5,
    );
    final List<Uint8List> imageBytes = await Future.wait(
      pickedFiles.map((pickedFile) async {
        return await pickedFile.readAsBytes();
      }).toList(),
    );

    if (mounted) {
      context.read<ChatBloc>().add(ChatAddImage(images: imageBytes));
    }
  }
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.dateDividerBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Text(
              date.toDateDivider(context),
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

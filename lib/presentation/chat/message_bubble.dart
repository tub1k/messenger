import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/gallery_screen.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String chatId;
  final DateTime? recentRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatId,
    required this.recentRead,
  });

  @override
  Widget build(BuildContext context) {
    final double blradius;
    final double brradius;
    final Color bubbleColor;
    final AlignmentGeometry alignment;
    if (isMe) {
      blradius = 20;
      brradius = 0;
      bubbleColor = context.colors.outgoingMessageBG;
      alignment = AlignmentGeometry.topRight;
    } else {
      blradius = 0;
      brradius = 20;
      bubbleColor = context.colors.incomingMessageBG;
      alignment = AlignmentGeometry.topLeft;
    }

    final MessageStatus status;
    final DateTime fixedRead = recentRead ?? DateTime(1970);
    if (message.isPending ?? false) {
      status = MessageStatus.pending;
    } else if (message.timestamp.isAfter(fixedRead)) {
      status = MessageStatus.sent;
    } else {
      status = MessageStatus.read;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
      child: Align(
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isMe)
              MessageContainer(
                blradius: blradius,
                brradius: brradius,
                bubbleColor: bubbleColor,
                message: message,
                chatId: chatId,
                isMe: isMe,
              ),
            SizedBox(width: 8),
            if (isMe)
              Padding(
                padding: EdgeInsets.only(top: 4, right: 4),
                child: switch (status) {
                  MessageStatus.pending => Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey,
                  ),
                  MessageStatus.sent => Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.grey,
                  ),
                  MessageStatus.read => Icon(
                    Icons.check_circle,
                    size: 12,
                    color: context.colors.defaultButtonColor,
                  ),
                  MessageStatus.error => Icon(
                    Icons.warning,
                    size: 12,
                    color: context.colors.leaveDeleteColor,
                  ),
                },
              ),
            Text(
              message.timestamp.toMessageTime(),
              style: TextStyle(color: context.colors.halfOpaqueText),
            ),
            SizedBox(width: 8),
            if (isMe)
              MessageContainer(
                blradius: blradius,
                brradius: brradius,
                bubbleColor: bubbleColor,
                message: message,
                chatId: chatId,
                isMe: isMe,
              ),
          ],
        ),
      ),
    );
  }
}

class MessageContainer extends StatelessWidget {
  const MessageContainer({
    super.key,
    required this.blradius,
    required this.brradius,
    required this.bubbleColor,
    required this.message,
    required this.chatId,
    required this.isMe,
  });

  final double blradius;
  final double brradius;
  final Color bubbleColor;
  final MessageModel message;
  final String chatId;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(blradius),
          bottomRight: Radius.circular(brradius),
        ),
        color: bubbleColor,
      ),
      padding: EdgeInsets.all(12),
      constraints: BoxConstraints(
        minWidth: 40,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: _buildCellWidget(message, context, chatId, isMe),
    );
  }
}

enum MessageStatus { pending, sent, read, error }

Widget _buildCellWidget(
  MessageModel msg,
  BuildContext context,
  String chatId,
  bool isMe,
) {
  switch (msg.type) {
    case MessageType.text:
      return Text(
        msg.text,
        style: TextStyle(color: context.colors.messageText),
      );
    case MessageType.image:
      return Builder(
        builder: (context) {
          if ((msg.isPending ?? false) && msg.optimisticImages != null) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...msg.optimisticImages!.map((img) {
                  return Container(
                    color: Colors.black,
                    child: Image.memory(
                      img,
                      height: 150,
                      width: 150,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  );
                }),
              ],
            );
          } else {
            final urls = context.read<IStorageRepository>().getMessagePhotos(
              chatId,
              msg,
            );
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...urls.asMap().entries.map((url) {
                  return GestureDetector(
                    onTap: () {
                      final chatBloc = context.read<ChatBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: chatBloc,
                            child: GalleryScreen(
                              imageUrls: urls,
                              initialIndex: url.key,
                              msg: msg,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: url.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.black,
                          child: FastCachedImage(
                            fadeInDuration: Duration.zero,
                            url: url.value,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, loadingProgress) {
                              return Container(
                                height: 150,
                                width: 150,
                                color: Colors.black12,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.black12,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }
        },
      );
    default:
      return Text(context.l10n.updateToSeeThisMessageType);
  }
}

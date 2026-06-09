import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/gallery_screen.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/widgets/relative_time_text.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String chatId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatId,
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
      bubbleColor = Colors.blue;
      alignment = AlignmentGeometry.topRight;
    } else {
      blradius = 0;
      brradius = 20;
      bubbleColor = Colors.grey;
      alignment = AlignmentGeometry.topLeft;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0),
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RelativeTimeText(
                    dateTime: message.timestamp,
                    isShort: true,
                    style: TextStyle(color: Colors.black38),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: _buildCellWidget(message, context, chatId, isMe),
                  ),
                ],
              ),
            ),
            if (message.isPending ?? false)
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 4),
                child: Icon(Icons.access_time, size: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

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
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
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
                          const Icon(Icons.broken_image, color: Colors.white,),
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
                          child: Image.network(
                            url.value,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
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
                                  child: const Icon(Icons.broken_image, color: Colors.white,),
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

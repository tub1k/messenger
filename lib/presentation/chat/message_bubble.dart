import 'package:flutter/material.dart';
import 'package:messenger/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

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
              child: _buildCellWidget(message),
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

Widget _buildCellWidget(MessageModel msg) {
  switch (msg.type) {
    case MessageType.text:
      return Text(msg.text);
    case MessageType.image:
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          msg.text,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        ),
      );
    default:
      return Text('Update the app to see this message type');
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/create_chat/bloc/create_chat_bloc.dart';

class CreateChatSecondColumn extends StatelessWidget {
  final CreateChatSecond curState;
  final TextEditingController chatNameController;
  final Uint8List? selectedImage;
  final VoidCallback onPickImage;

  const CreateChatSecondColumn({
    super.key,
    required this.chatNameController,
    required this.selectedImage,
    required this.onPickImage,
    required this.curState,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = MediaQuery.of(context).size.width * 0.6;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Text(context.l10n.chatName, style: TextStyle(fontSize: 24)),
          TextField(
            controller: chatNameController,
            decoration: InputDecoration(hintText: context.l10n.chatNameHint),
          ),
          Text(context.l10n.addChatPicture, style: TextStyle(fontSize: 24)),
          Ink(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
              image: selectedImage != null
                  ? DecorationImage(
                      image: MemoryImage(selectedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPickImage,
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: selectedImage != null
                    ? null
                    : Icon(Icons.add, size: avatarSize / 2),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TextButton(
                  onPressed: () {
                    context.read<CreateChatBloc>().add(
                      CreateChat(
                        addedUsers: curState.addedUsers,
                        photo: selectedImage,
                        chatName: chatNameController.text.trim(),
                      ),
                    );
                  },
                  child: Text(context.l10n.createChat),
                ),
              ),
            ),
          ),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

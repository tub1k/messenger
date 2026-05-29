import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/chat_screen.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/create_chat/bloc/create_chat_bloc.dart';
import 'package:messenger/presentation/create_chat/create_chat_initial_column.dart';
import 'package:messenger/presentation/create_chat/create_chat_second_column.dart';

class CreateChatSheet extends StatefulWidget {
  const CreateChatSheet({super.key});

  @override
  State<CreateChatSheet> createState() => _CreateChatSheetState();
}

class _CreateChatSheetState extends State<CreateChatSheet> {
  late TextEditingController _addToChatController;
  late TextEditingController _chatNameController;

  final _picker = ImagePicker();
  Uint8List? selectedImage;

  @override
  void initState() {
    _addToChatController = TextEditingController();
    _chatNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _addToChatController.dispose();
    _chatNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext oldContext) {
    return BlocProvider(
      create: (context) => CreateChatBloc(
        repository: context.read<IChatRepository>(),
        storageRepository: context.read<IStorageRepository>(),
        myId: (context.read<AuthBloc>().state as AuthSuccess).userId,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocConsumer<CreateChatBloc, CreateChatState>(
              listener: (context, state) {
                if (state.errorText != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorText ?? ''),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is CreateChatMoveToChat) {
                  final chat = state.chat;
                  final repo = context.read<IChatRepository>();
                  final currentUserId = context.myId!;
                  Navigator.pushReplacement(
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
                }
              },
              builder: (context, state) {
                final curState = state;
                if (curState is CreateChatInitial) {
                  return CreateChatInitialColumn(
                    addToChatController: _addToChatController,
                    curState: curState,
                  );
                } else if (curState is CreateChatSecond) {
                  return CreateChatSecondColumn(
                    chatNameController: _chatNameController,
                    selectedImage: selectedImage,
                    curState: curState,
                    onPickImage: () async {
                      final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 60,
                        maxWidth: 400,
                        maxHeight: 400,
                      );
                      final Uint8List? imageBytes = await pickedFile
                          ?.readAsBytes();
                      if (imageBytes != null) {
                        setState(() {
                          selectedImage = imageBytes;
                        });
                      }
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        },
      ),
    );
  }
}

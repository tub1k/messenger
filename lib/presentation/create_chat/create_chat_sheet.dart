import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/presentation/create_chat/bloc/create_chat_bloc.dart';

class CreateChatSheet extends StatefulWidget {
  const CreateChatSheet({super.key});

  @override
  State<CreateChatSheet> createState() => _CreateChatSheetState();
}

class _CreateChatSheetState extends State<CreateChatSheet> {
  late TextEditingController _addToChatController;

  @override
  void initState() {
    _addToChatController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _addToChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext oldContext) {
    return BlocProvider(
      create: (context) =>
          CreateChatBloc(repository: context.read<IChatRepository>()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: BlocConsumer<CreateChatBloc, CreateChatState>(
              listener: (context, state) {
                if (state is CreateChatInitial && state.errorText != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorText ?? ''),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  spacing: 10,
                  children: [
                    SizedBox(height: 10,),
                    Text('New Chat', style: TextStyle(fontSize: 20),),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        controller: _addToChatController,
                        decoration: InputDecoration(
                          hintText: 'enter users tags to add them to chat',
                        ),
                        onSubmitted: (text) {
                          context.read<CreateChatBloc>().add(
                            AddToCreateChatList(
                              username: text.trim().toLowerCase(),
                            ),
                          );
                          //_addToChatController.clear();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

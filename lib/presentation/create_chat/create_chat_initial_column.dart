import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/presentation/create_chat/bloc/create_chat_bloc.dart';

class CreateChatInitialColumn extends StatelessWidget {
  const CreateChatInitialColumn({
    super.key,
    required TextEditingController addToChatController,
    required this.curState,
  }) : _addToChatController = addToChatController;

  final TextEditingController _addToChatController;
  final CreateChatInitial curState;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        SizedBox(height: 10),
        Text('New Chat', style: TextStyle(fontSize: 20)),
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _addToChatController,
            decoration: InputDecoration(
              hintText: 'enter users tags to add them to chat',
            ),
            onSubmitted: (text) {
              context.read<CreateChatBloc>().add(
                AddToCreateChatList(username: text.trim().toLowerCase()),
              );
              //_addToChatController.clear();
            },
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: curState.addedUsers.map((user) {
            return InputChip(
              label: Text(
                '${user.displayName} ${user.isUsernameEqualToDisplayName ? '' : '(@${user.username})'}',
              ),
              onDeleted: () {
                context.read<CreateChatBloc>().add(
                  RemoveFromCreateChatList(username: user.username ?? ''),
                );
              },
            );
          }).toList(),
        ),
        Expanded(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: TextButton(
                  onPressed: () {
                    context.read<CreateChatBloc>().add(
                      GoToSecondPage(addedUsers: curState.addedUsers),
                    );
                  },
                  child: Text('confirm'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

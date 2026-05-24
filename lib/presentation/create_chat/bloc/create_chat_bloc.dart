import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

part 'create_chat_event.dart';
part 'create_chat_state.dart';

class CreateChatBloc extends Bloc<CreateChatEvent, CreateChatState> {
  final IChatRepository _repository;
  final String myId;
  CreateChatBloc({required IChatRepository repository, required this.myId})
    : _repository = repository,
      super(CreateChatInitial(addedUsers: [])) {
    on<CreateChatEvent>((event, emit) {});

    on<AddToCreateChatList>((event, emit) async {
      //TODO: add checking if its myid
      final currentState = state;
      if (currentState is CreateChatInitial) {
        try {
          final newUser = await _repository.getBaseUserByUsername(
            event.username,
          );
          if (currentState.addedUsers.contains(newUser)) {
            throw 'user already in list!';
          }
          emit(
            CreateChatInitial(addedUsers: currentState.addedUsers + [newUser]),
          );
        } catch (e) {
          emit(
            CreateChatInitial(
              addedUsers: currentState.addedUsers,
              errorText: e.toString(),
            ),
          );
        }
      } else {
        emit(
          CreateChatInitial(
            addedUsers: [],
            errorText: 'tried to add user while on wrong screen',
          ),
        );
      }
    });

    on<RemoveFromCreateChatList>((event, emit) {
      final currentState = state;
      try {
        if (currentState is CreateChatInitial) {
          var newList = currentState.addedUsers;
          newList.removeWhere((user) => user.username == event.username);
          emit(CreateChatInitial(addedUsers: newList));
        }
      } catch (e) {
        emit(
          CreateChatInitial(
            addedUsers: [],
            errorText: 'tried to add user while on wrong screen',
          ),
        );
      }
    });

    on<GoToSecondPage>((event, emit) async {
      final curState = state; // current state
      final users = event.addedUsers.toList();
      if (curState is! CreateChatInitial) return;
      if (users.length == 1) {
        emit(CreateChatLoading());
        try {
        final targetUserUid = users[0].uid; 
        final dm = await _repository.getDms(
          myId,
          targetUserUid,
          myId,
        );
        if (dm != null) {
          emit(CreateChatMoveToChat(chat: dm));
        } else {
          final createdChatId = await _repository.createChat(
            userUids: [myId, targetUserUid],
          ); // TODO: make it emit loading and going to chat when chat is successfully created.
          final createdChat = await _repository.getChatObject(
            createdChatId,
            myId,
          );
          if (createdChat != null) {
            emit(CreateChatMoveToChat(chat: createdChat));
          } else {
            throw 'failed to create chat';
          }
        }} catch (e) {
          emit(
              CreateChatInitial(
                addedUsers: users,
                errorText: e.toString(),
              ));
        }
      } else if (event.addedUsers.length > 1) {
        emit(CreateChatSecond(addedUsers: users));
      } else {
        emit(
          CreateChatInitial(
            addedUsers: users,
            errorText: 'Add someone first!',
          ),
        );
      }
    });
  }
}

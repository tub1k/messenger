import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class ProfileBlocEvent {}

class ProfileSendDM extends ProfileBlocEvent {}

class ProfileSubscribe extends ProfileBlocEvent {}

class ProfileFriendButton extends ProfileBlocEvent {}

class ProfileBlocState {
  final String? errorText;
  final BaseUserModel user;

  ProfileBlocState({this.errorText, required this.user});}

class ProfileBlocInitial extends ProfileBlocState {
  ProfileBlocInitial({super.errorText, required super.user});
}

class ProfilePushChat extends ProfileBlocState {
  final ChatModel chat;

  ProfilePushChat({required this.chat, required super.user, super.errorText});
}

class ProfileBloc extends Bloc<ProfileBlocEvent, ProfileBlocState> {
  final IChatRepository _chatRepository;
  final BaseUserModel initialUser;
  final String myId;
  ProfileBloc({
    required IChatRepository chatRepository,
    required this.myId,
    required this.initialUser,
  }) : _chatRepository = chatRepository,
       super(ProfileBlocInitial(user: initialUser)) {
    on<ProfileSubscribe>((event, emit) async {
      await emit.forEach(
        _chatRepository.streamUserPresence(initialUser.uid),
        onData: (user) {
          return ProfileBlocInitial(user: user);
        },
        onError: (e, stackTrace) {
          return ProfileBlocInitial(errorText: e.toString(), user: state.user);
        },
      );
    });

    on<ProfileSendDM>((event, emit) async {
      try {
        final chat = await _chatRepository.getDms(myId, state.user.uid, myId);
        if (chat != null) {
              emit(ProfilePushChat(chat: chat, user: state.user));
            } else {
              final createdChatId = await _chatRepository.createChat(
                userUids: [myId, state.user.uid],
              );
              final createdChat = await _chatRepository.getChatObject(
                createdChatId,
                myId,
              );
              if (createdChat != null) {
                emit(ProfilePushChat(chat: createdChat, user: state.user));
              } else {
                throw 'failed_to_create_chat';
              }
            }
      } catch (e) {
        emit(ProfileBlocInitial(errorText: e.toString(), user: state.user));
      }
    });

    on<ProfileFriendButton>((event, emit) async {
      try {
        await _chatRepository.sendFriendRequest(state.user.uid, myId);
      } catch (e) {
        log(e.toString());
        emit(ProfileBlocInitial(user: state.user, errorText: e.toString()));
      }
    });
  }
}

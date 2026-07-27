// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/user_relations_bloc.dart';

class FriendsListEvent {}

class FriendsListInit extends FriendsListEvent {}

class FriendsListDataReceived extends FriendsListEvent {
  final List<BaseUserModel> friends;
  final List<BaseUserModel> incomingInvites;
  final List<BaseUserModel> outgoingInvites;

  FriendsListDataReceived({
    required this.friends,
    required this.incomingInvites,
    required this.outgoingInvites,
  });
}

class FriendsListDMButton extends FriendsListEvent {
  final String uid;
  final String myId;

  FriendsListDMButton({required this.uid, required this.myId});
} 

class FriendsListState {}

class FriendsListLoading extends FriendsListState {}

class FriendsListLoaded extends FriendsListState {
  final List<BaseUserModel> friends;
  final List<BaseUserModel> incomingInvites;
  final List<BaseUserModel> outgoingInvites;
  final String searchQuery;
  final ChatModel? chatToPush;
  final String? errorText;

  FriendsListLoaded({
    required this.friends,
    required this.incomingInvites,
    required this.outgoingInvites,
    this.searchQuery = '',
    this.chatToPush,
    this.errorText,
  });

  FriendsListLoaded copyWith({
    List<BaseUserModel>? friends,
    List<BaseUserModel>? incomingInvites,
    List<BaseUserModel>? outgoingInvites,
    String? searchQuery,
    ChatModel? chatToPush,
    String? errorText,
  }) {
    return FriendsListLoaded(
      friends: friends ?? this.friends,
      incomingInvites: incomingInvites ?? this.incomingInvites,
      outgoingInvites: outgoingInvites ?? this.outgoingInvites,
      searchQuery: searchQuery ?? this.searchQuery,
      chatToPush: chatToPush ?? this.chatToPush,
      errorText: errorText ?? this.errorText,
    );
  }
}

class FriendsListBloc extends Bloc<FriendsListEvent, FriendsListState> {
  final IChatRepository _chatRepository;
  final UserRelationsBloc _relationsBloc;
  StreamSubscription? _relationsSubscription;
  FriendsListBloc({
    required IChatRepository chatRepository,
    required UserRelationsBloc relationsBloc,
  }) : _chatRepository = chatRepository,
       _relationsBloc = relationsBloc,
       super(FriendsListLoading()) {
    on<FriendsListInit>((event, emit) async {
      await _relationsSubscription?.cancel();

      Future<void> fetchUsers(UserRelationsState state) async {
        final people = await Future.wait([
          _chatRepository.getBaseUsersFromListOfUIDs(state.friendIds.toList()),
          _chatRepository.getBaseUsersFromListOfUIDs(
            state.incomingInviteIds.toList(),
          ),
          _chatRepository.getBaseUsersFromListOfUIDs(
            state.outgoingInviteIds.toList(),
          ),
        ]);
        add(
          FriendsListDataReceived(
            friends: people[0],
            incomingInvites: people[1],
            outgoingInvites: people[2],
          ),
        );
      }

      _relationsSubscription = _relationsBloc.stream.distinct().listen((
        state,
      ) async {
        await fetchUsers(state);
      });
      final state = _relationsBloc.state;
      await fetchUsers(state);
    });
    on<FriendsListDataReceived>((event, emit) {
      emit(
        FriendsListLoaded(
          friends: event.friends,
          incomingInvites: event.incomingInvites,
          outgoingInvites: event.outgoingInvites,
        ),
      );
    });
    on<FriendsListDMButton>((event, emit) async {
      final curState = state;
      final myId = event.myId;
      if (curState is! FriendsListLoaded) return;
      try {
        final chat = await _chatRepository.getDms(myId, event.uid, myId);
        if (chat != null) {
          emit(curState.copyWith(chatToPush: chat));
        } else {
          final createdChatId = await _chatRepository.createChat(
            userUids: [myId, event.uid],
          );
          final createdChat = await _chatRepository.getChatObject(
            createdChatId,
            myId,
          );
          if (createdChat != null) {
            curState.copyWith(chatToPush: createdChat);
          } else {
            throw 'failed_to_create_chat';
          }
        }
      } catch (e) {
        emit(curState.copyWith(errorText: e.toString()));
      }
    });
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
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

class FriendsListState {}

class FriendsListLoading extends FriendsListState {}

class FriendsListLoaded extends FriendsListState {
  final List<BaseUserModel> friends;
  final List<BaseUserModel> incomingInvites;
  final List<BaseUserModel> outgoingInvites;
  final String searchQuery;

  FriendsListLoaded({
    this.searchQuery = '',
    required this.friends,
    required this.incomingInvites,
    required this.outgoingInvites,
  });
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
  }
}

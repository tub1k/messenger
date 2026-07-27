import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/domain/repositories/i_relations_repository.dart';

class UserRelationsState {
  final Set<String> friendIds;
  final Set<String> incomingInviteIds;
  final Set<String> outgoingInviteIds;
  final Set<String> blockedIds;
  final String? errorText;

  UserRelationsState({
    required this.friendIds,
    required this.incomingInviteIds,
    required this.outgoingInviteIds,
    required this.blockedIds,
    this.errorText,
  });

  UserRelationsState.empty()
    : friendIds = const <String>{},
      incomingInviteIds = const <String>{},
      outgoingInviteIds = const <String>{},
      blockedIds = const <String>{},
      errorText = null;

  UserRelationsState copyWith({
    Set<String>? friendIds,
    Set<String>? incomingInviteIds,
    Set<String>? outgoingInviteIds,
    Set<String>? blockedIds,
    String? errorText,
  }) {
    return UserRelationsState(
      friendIds: friendIds ?? this.friendIds,
      incomingInviteIds: incomingInviteIds ?? this.incomingInviteIds,
      outgoingInviteIds: outgoingInviteIds ?? this.outgoingInviteIds,
      blockedIds: blockedIds ?? this.blockedIds,
    );
  }
}

class UserRelationsEvent {}

class UserRelationsInit extends UserRelationsEvent {}

class RelationsSendInvite extends UserRelationsEvent {
  final String uid;
  RelationsSendInvite({required this.uid});
}

class RelationsAcceptInvite extends UserRelationsEvent {
  final String uid;

  RelationsAcceptInvite({required this.uid});
}

class RelationsRecallInvite extends UserRelationsEvent {
  final String uid;

  RelationsRecallInvite({required this.uid});
}

class RelationsRemoveFriend extends UserRelationsEvent {
  final String uid;

  RelationsRemoveFriend({required this.uid});
}

class RelationsDeclineInvite extends UserRelationsEvent {
  final String uid;

  RelationsDeclineInvite({required this.uid});
}

class UserRelationsBloc extends Bloc<UserRelationsEvent, UserRelationsState> {
  final IRelationsRepository _relationsRepository;
  final String myId;

  UserRelationsBloc({
    required IRelationsRepository relationsRepository,
    required this.myId,
  }) : _relationsRepository = relationsRepository,
       super(UserRelationsState.empty()) {
    on<UserRelationsInit>((event, emit) async {
      await emit.forEach(
        _relationsRepository.relationsStream(myId),
        onData: (state) {log(state.outgoingInviteIds.toString()); return state;},
      );
    });
    on<RelationsSendInvite>((event, emit) async {
      try {
        await _relationsRepository.sendFriendRequest(event.uid, myId);
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
    });
    on<RelationsAcceptInvite>((event, emit) async {
      try {
        await _relationsRepository.acceptFriendRequest(event.uid, myId);
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
    });
    on<RelationsRecallInvite>((event, emit) async {
      try {
        await _relationsRepository.recallFriendRequest(event.uid, myId);
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
    });
    on<RelationsRemoveFriend>((event, emit) async {
      try {
        await _relationsRepository.sendFriendRequest(event.uid, myId);
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
    });
    on<RelationsDeclineInvite>((event, emit) async {
      try {
        await _relationsRepository.declineFriendRequest(event.uid, myId);
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
    });
  }
}

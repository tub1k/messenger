import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_relations_repository.dart';

class UserRelationsState {
  final Set<String> friendIds;
  final Set<String> incomingInviteIds;
  final Set<String> outgoingInviteIds;
  final Set<String> blockedIds;

  UserRelationsState({
    required this.friendIds,
    required this.incomingInviteIds,
    required this.outgoingInviteIds,
    required this.blockedIds,
  });

  UserRelationsState.empty()
    : friendIds = const <String>{},
      incomingInviteIds = const <String>{},
      outgoingInviteIds = const <String>{},
      blockedIds = const <String>{};
}

class UserRelationsEvent {}

class UserRelationsInit extends UserRelationsEvent {}

class RelationsSendInvite extends UserRelationsEvent {}

class RelationsAcceptInvite extends UserRelationsEvent {}

class RelationsRecallInvite extends UserRelationsEvent {}

class RelationsRemoveFriend extends UserRelationsEvent {}

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
        onData: (state) => state,
      );
    });
    on<RelationsSendInvite>((event, emit) async {});
  }
}

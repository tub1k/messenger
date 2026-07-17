import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class UserRelationsState {
  final Set<String> friendIds;
  final Set<String> incomingInviteIds;
  final Set<String> outgoingInviteIds;
  final Set<String> blockedIds;

  UserRelationsState({required this.friendIds, required this.incomingInviteIds, required this.outgoingInviteIds, required this.blockedIds});
  
  UserRelationsState.empty()
    : friendIds = {} as Set<String>,
      incomingInviteIds = {} as Set<String>,
      outgoingInviteIds = {} as Set<String>,
      blockedIds = {} as Set<String>;
}

class UserRelationsEvent {}

class UserRelationsInit extends UserRelationsEvent {}

class UserRelationsBloc extends Bloc<UserRelationsEvent, UserRelationsState> {
  final IChatRepository _chatRepository;
  final String myId;

  UserRelationsBloc({required IChatRepository chatRepository, required this.myId}) : _chatRepository = chatRepository, super(UserRelationsState.empty()) {
    on<UserRelationsInit>((event, emit) async {
      await emit.forEach(_chatRepository.relationsStream(myId), onData: (state) => state);
    });
  }
}
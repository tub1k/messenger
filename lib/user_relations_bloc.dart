import 'package:flutter_bloc/flutter_bloc.dart';

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
  UserRelationsBloc() : super(UserRelationsState.empty()) {
    on<UserRelationsInit>((event, emit) {
      
    });
  }
}
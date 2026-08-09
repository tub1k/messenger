import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';

class MyProfileEvent {}

class MyProfileInit extends MyProfileEvent {}

class MyProfileBioChanged extends MyProfileEvent {
  final String bio;

  MyProfileBioChanged({required this.bio});
}

class MyProfileState {}

class MyProfileInitial extends MyProfileState {}

class MyProfileLoaded extends MyProfileState {
  final BaseUserModel user;

  MyProfileLoaded({required this.user});
}

class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState> {
  final String myId;
  final IChatRepository repository;
  MyProfileBloc({required this.myId, required this.repository}) : super(MyProfileInitial()) {
    on<MyProfileInit>((event, emit) async {
      final user = await repository.getBaseUserByUID(myId);
      emit(MyProfileLoaded(user: user));
    });
    on<MyProfileBioChanged>((event, emit) {
      repository.changeBio(event.bio, myId);
    });
  }
}
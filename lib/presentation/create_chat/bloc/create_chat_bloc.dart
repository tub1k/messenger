import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

part 'create_chat_event.dart';
part 'create_chat_state.dart';

class CreateChatBloc extends Bloc<CreateChatEvent, CreateChatState> {
  final IChatRepository _repository;
  CreateChatBloc({required IChatRepository repository})
    : _repository = repository,
      super(CreateChatInitial(addedUsers: [])) {
    on<CreateChatEvent>((event, emit) {});

    on<AddToCreateChatList>((event, emit) async {
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

    on<GoToSecondPage>((event, emit) {
      emit(CreateChatSecond(addedUsers: event.addedUsers));
    });
  }
}

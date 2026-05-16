import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  AuthBloc({required IAuthRepository repository})
    : _repository = repository,
      super(AuthInitial()) {
    on<AuthEvent>((event, emit) {});

    on<AuthStarted>((event, emit) async {
      await emit.forEach<String?>(
        _repository.authStateChanges,
        onData: (uid) {
          if (uid != null) {
            return AuthSuccess(uid);
          } else {
            return AuthInitial();
          }
        },
        onError: (e, _) => AuthInitial(errorText: e.toString()),
      );
    });

    on<AuthSignInEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repository.signInWithEmail(event.email, event.password);
      } catch (e) {
        emit(AuthInitial(errorText: e.toString()));
      }
    });

    on<AuthSignUpEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repository.signUpWithEmail(event.email, event.password);
      } catch (e) {
        emit(AuthInitial(errorText: e.toString()));
      }
    });
  }
}

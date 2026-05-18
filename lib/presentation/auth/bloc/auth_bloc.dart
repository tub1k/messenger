import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  StreamSubscription<String?>? _authSubscription;

  AuthBloc({required IAuthRepository repository})
    : _repository = repository,
      super(AuthInitial()) {

    // on<AuthStarted>((event, emit) async {
    //   await emit.forEach<String?>(
    //     _repository.authStateChanges,
    //     onData: (uid) {
    //       if (uid != null) {
    //         return AuthSuccess(uid);
    //       } else {
    //         return AuthInitial();
    //       }
    //     },
    //     onError: (e, _) => AuthInitial(errorText: e.toString()),
    //   );
    // });

    on<_AuthStatusChanged>((event, emit) {
      if (state is AuthLoading) return;

      if (event.uid != null) {
        emit(AuthSuccess(event.uid!));
      } else {
        emit(AuthInitial());
      }
    });

    on<AuthSignInEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final uid = await _repository.signInWithEmail(event.email, event.password);
        emit(AuthSuccess(uid));
      } catch (e) {
        emit(AuthInitial(errorText: e.toString()));
      }
    });

    on<AuthSignUpEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final uid = await _repository.signUpWithEmail(event.email, event.password, event.username);
        emit(AuthSuccess(uid));
      } catch (e) {
        emit(AuthInitial(errorText: e.toString()));
      }
    });
    on<AuthGoToUsernameScreen>((event, emit) async {
      emit(AuthEnterUsername());
    });

    _authSubscription = _repository.authStateChanges.listen((uid) {
      add(_AuthStatusChanged(uid));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel(); 
    return super.close();
  }
}
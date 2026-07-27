import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/core/services/notification_service.dart';
import 'package:messenger/domain/repositories/i_auth_repository.dart';
import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  final SettingsBloc _settingsBloc;
  StreamSubscription<String?>? _authSubscription;

  AuthBloc({required IAuthRepository repository, required SettingsBloc settingsBloc})
    : _settingsBloc = settingsBloc, _repository = repository,
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

    on<_AuthStatusChanged>((event, emit) async {
      if (state is AuthLoading) return;

      if (event.uid != null) {
        emit(AuthSuccess(event.uid!));
        await NotificationService().initialize(event.uid!, _settingsBloc);
      } else {
        await NotificationService().removeToken(event.uid);
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
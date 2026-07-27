import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/domain/repositories/i_auth_repository.dart';

abstract class OnlineStatusEvent {}

class _LifecycleChangedEvent extends OnlineStatusEvent {
  final AppLifecycleState state;
  _LifecycleChangedEvent(this.state);
}

abstract class OnlineStatusState {}

class OnlineStatusInitial extends OnlineStatusState {}

class OnlineStatusBloc extends Bloc<OnlineStatusEvent, OnlineStatusState> {
  final IAuthRepository _repository;
  final String _userId;

  Timer? _heartbeatTimer;
  late final AppLifecycleListener _lifecycleListener;
  OnlineStatusBloc({
    required IAuthRepository repository,
    required String userId,
  }) : _repository = repository,
       _userId = userId,
       super(OnlineStatusInitial()) {
    on<_LifecycleChangedEvent>(_onLifecycleChanged);

    // listening for state changes
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) => add(_LifecycleChangedEvent(state)),
    );

    _updateStatus(isOnline: true);
    _startHeartbeat();
  }

  Future<void> _onLifecycleChanged(
    _LifecycleChangedEvent event, 
    Emitter<OnlineStatusState> emit,
  ) async {
    if (event.state == AppLifecycleState.resumed) {
      _updateStatus(isOnline: true);
      _startHeartbeat();
    } else if (event.state == AppLifecycleState.paused || 
               event.state == AppLifecycleState.detached) {
      _stopHeartbeat();
      await _updateStatus(isOnline: false);
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateStatus(isOnline: true);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  Future<void> _updateStatus({required bool isOnline}) async {
    try {
      await _repository.updateUserOnlineStatus(
        userId: _userId,
        isOnline: isOnline,
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _lifecycleListener.dispose();
    _stopHeartbeat();
    return super.close();
  }
}

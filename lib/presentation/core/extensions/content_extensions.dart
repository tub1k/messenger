import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';

extension AuthExtensionX on BuildContext {

  /// if used after user is authorised, returns his UID, otherwise null
  String? get myId {
    final curState = read<AuthBloc>().state;
    if (curState is AuthSuccess) return curState.userId;
    return null;
  } 
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';
import 'package:messenger/data/repository/firebase_auth_repository.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/test/mocks/mock_chat_repository.dart';
import 'package:messenger/firebase_options.dart';
import 'package:messenger/presentation/chat/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/chat/auth/auth_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/presentation/chat_list/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IChatRepository>(
          create: (context) => MockChatRepository(),
        ),
        RepositoryProvider<IAuthRepository>(
          create: (context) => FirebaseAuthRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Aura Messenger',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthProvider(), 
      ),
    );
  }
}

// Обертка-провайдер для экрана авторизации
class AuthProvider extends StatelessWidget {
  const AuthProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        repository: context.read<IAuthRepository>(),
      )..add(AuthStarted()),
      child: const AuthScreen(),
    );
  }
}

// Твоя обертка-провайдер для экрана чатов (остается без изменений)
class ChatListProvider extends StatelessWidget {
  const ChatListProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatListBloc(
        context.read<IChatRepository>(),
      )..add(InitChatList()),
      child: const ChatListScreen(),
    );
  }
}
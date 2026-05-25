import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/firebase_chat_repository.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';
import 'package:messenger/data/repository/firebase_auth_repository.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/firebase_options.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/auth/auth_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/presentation/chat_list/chat_list_screen.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';

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
          create: (context) => FirebaseChatRepository(),
        ),
        RepositoryProvider<IAuthRepository>(
          create: (context) => FirebaseAuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              repository: context.read<IAuthRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Aura Messenger',
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return const ChatListProvider();
              }
              
              return const AuthScreen();
            },
        ),
      ),
    ));
  }
}

class ChatListProvider extends StatelessWidget {
  const ChatListProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = context.myId!;
    return BlocProvider(
      create: (context) => ChatListBloc(
        context.read<IChatRepository>(),
        myId: myId, 
      )..add(InitChatList()),
      child: const ChatListScreen(),
    );
  }
}
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/firebase_chat_repository.dart';
import 'package:messenger/data/repository/firebase_relations_repository.dart';
import 'package:messenger/domain/repositories/i_auth_repository.dart';
import 'package:messenger/data/repository/firebase_auth_repository.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/domain/repositories/i_image_repository.dart';
import 'package:messenger/domain/repositories/i_relations_repository.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';
import 'package:messenger/data/repository/image_repository_impl.dart';
import 'package:messenger/data/repository/settings_repository.dart';
import 'package:messenger/data/repository/supabase_storage_repository.dart';
import 'package:messenger/firebase_options.dart';
import 'package:messenger/l10n/app_localizations.dart';
import 'package:messenger/online_status_bloc.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/auth/auth_screen.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/chat_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/core/environment/environment.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/main_scaffold/main_scaffold.dart';
import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';
import 'package:messenger/user_relations_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // safe firebase initializing
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      Firebase.app();
    } else {
      rethrow;
    }
  }

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseApiKey,
  );
  // initializing settings
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  // init other stuff
  _initializeTimeAgo();
  await FastCachedImageConfig.init();
  // run the app
  runApp(MyApp(settingsRepository: settingsRepository));
}

class MyApp extends StatelessWidget {
  final SettingsRepository settingsRepository;
  const MyApp({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
        RepositoryProvider<IStorageRepository>(
          create: (context) => SupabaseStorageRepository(),
        ),
        RepositoryProvider<IChatRepository>(
          create: (context) => FirebaseChatRepository(
            storageRepository: context.read<IStorageRepository>(),
          ),
        ),
        RepositoryProvider<IAuthRepository>(
          create: (context) => FirebaseAuthRepository(),
        ),
        RepositoryProvider<IImageRepository>(
          create: (context) => ImageRepositoryImpl(),
        ),
        RepositoryProvider<IRelationsRepository>(
          create: (context) => FirebaseRelationsRepository(
            chatRepository: context.read<IChatRepository>(),
          ),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (context) =>
                SettingsBloc(context.read<SettingsRepository>()),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              repository: context.read<IAuthRepository>(),
              settingsBloc: context.read<SettingsBloc>(),
            ),
          ),
          BlocProvider<UserRelationsBloc>(
            create: (context) => UserRelationsBloc(
              relationsRepository: context.read<IRelationsRepository>(),
              myId: context.myId!,
            )..add(UserRelationsInit()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'Aura messenger',
              locale: settingsState.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: settingsState.themeData,
              themeMode: ThemeMode.light,
              home: BlocListener<SettingsBloc, SettingsState>(
                listener: (context, settingsState) {
                  final data = settingsState.navigateToData;
                  if (data != null) {
                    if (data['type'] == 'chat' && data['id'] != null) {
                      _pushChat(context, data['id']);
                    }

                    context.read<SettingsBloc>().add(SettingsResetNavigation());
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthSuccess) {
                      return const ChatListProvider();
                    }
                    return const AuthScreen();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChatListProvider extends StatelessWidget {
  const ChatListProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final myId = context.myId!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ChatListBloc(context.read<IChatRepository>(), myId: myId)
                ..add(InitChatList()),
        ),
        BlocProvider<OnlineStatusBloc>(
          lazy: false,
          create: (context) => OnlineStatusBloc(
            repository: context.read<IAuthRepository>(),
            userId: context.myId!,
          ),
        ),
      ],
      child: const MainScaffold(currentIndex: 0),
    );
  }
}

void _initializeTimeAgo() {
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());
}

Future<void> _pushChat(BuildContext context, String chatId) async {
  final repo = context.read<IChatRepository>();
  final storageRepo = context.read<IStorageRepository>();
  final imageRepo = context.read<IImageRepository>();
  final currentUserId = context.myId!;
  final chat = await repo.getChatObject(chatId, context.myId!);
  if (chat != null && context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (navContext) => BlocProvider(
          create: (blocContext) => ChatBloc(
            repository: repo,
            storageRepository: storageRepo,
            imageRepository: imageRepo,
            myId: currentUserId,
            chat: chat,
          )..add(ChatStarted(chat.chatId)),
          child: ChatScreen(chat: chat),
        ),
      ),
    );
  }
}

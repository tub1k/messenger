import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/firebase_chat_repository.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';
import 'package:messenger/data/repository/firebase_auth_repository.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_image_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:messenger/data/repository/image_repository_impl.dart';
import 'package:messenger/data/repository/settings_repository.dart';
import 'package:messenger/data/repository/supabase_storage_repository.dart';
import 'package:messenger/firebase_options.dart';
import 'package:messenger/l10n/app_localizations.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:messenger/presentation/auth/auth_screen.dart';
import 'package:messenger/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:messenger/presentation/core/environment/environment.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/main_scaffold/main_scaffold.dart';
import 'package:messenger/presentation/settings/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseApiKey,
  );
  // initializing settings
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  runApp(MyApp(settingsRepository: settingsRepository,));
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

      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(repository: context.read<IAuthRepository>()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(context.read<SettingsRepository>()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'Aura messenger',
              locale: settingsState.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthSuccess) {
                    return const ChatListProvider();
                  }
                  return const AuthScreen();
                },
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
    return BlocProvider(
      create: (context) =>
          ChatListBloc(context.read<IChatRepository>(), myId: myId)
            ..add(InitChatList()),
      child: const MainScaffold(currentIndex: 0), 
    );
  }
}

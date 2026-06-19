import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/config/app_config.dart';
import 'package:starter_app/core/notifications/notification_service.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:starter_app/features/lists/data/list_repository.dart';
import 'package:starter_app/features/todos/data/sources/local_todo_source.dart';
import 'package:starter_app/features/todos/data/sources/remote_todo_source.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  await NotificationService.init();

  final settings = SettingsNotifier();
  await settings.init();

  final auth = AuthRepository();
  await auth.init();

  final listRepo = ListRepository();
  final todoRepo = TodoRepository();

  // Wire the correct data source for the current user.
  // Called at startup and again on every sign-in / sign-out.
  Future<void> setupForUser() async {
    if (!auth.isReady) return;
    await listRepo.init(auth.user?.id);
    await _attachSource(listRepo, todoRepo, auth);
  }

  await setupForUser();
  auth.addListener(setupForUser);
  // Re-attach when the active list changes (user switches lists).
  listRepo.addListener(() => _attachSource(listRepo, todoRepo, auth));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: listRepo),
        ChangeNotifierProvider.value(value: todoRepo),
      ],
      child: const TodoApp(),
    ),
  );
}

Future<void> _attachSource(
  ListRepository listRepo,
  TodoRepository todoRepo,
  AuthRepository auth,
) async {
  final active = listRepo.active;
  if (active.isLocal) {
    final src = LocalTodoSource();
    await src.init();
    todoRepo.attachSource(src);
  } else {
    todoRepo.attachSource(
      RemoteTodoSource(active.id, currentUserId: auth.user?.id),
    );
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLight(settings.colorProfile),
      darkTheme: AppTheme.buildDark(settings.colorProfile),
      themeMode: settings.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const _AuthGate(),
    );
  }
}

/// Shows [AuthScreen] until auth is ready, then switches to [TodoListScreen].
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    if (!auth.isReady) return const AuthScreen();
    return const TodoListScreen();
  }
}

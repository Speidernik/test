import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsNotifier();
  await settings.init();
  final todos = TodoRepository();
  await todos.loadTodos();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: todos),
      ],
      child: const TodoApp(),
    ),
  );
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
      home: const TodoListScreen(),
    );
  }
}

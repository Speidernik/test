import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/lists/data/list_repository.dart';
import 'package:starter_app/features/lists/data/models/todo_list.dart';
import 'package:starter_app/features/todos/data/models/todo_model.dart';
import 'package:starter_app/features/todos/data/sources/todo_data_source.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_list_screen.dart';

// ─── In-memory data source (no platform channels) ────────────────────────────

class _MemoryTodoSource implements TodoDataSource {
  final _controller = StreamController<List<Todo>>.broadcast();
  final List<Todo> _todos = [];

  _MemoryTodoSource() {
    // Emit empty list immediately so the stream has an initial value
    scheduleMicrotask(() => _controller.add([]));
  }

  @override
  Stream<List<Todo>> watchAll() => _controller.stream;

  @override
  Future<void> add(Todo todo) async {
    _todos.insert(0, todo);
    _controller.add(List.unmodifiable(_todos));
  }

  @override
  Future<void> update(Todo todo) async {
    final i = _todos.indexWhere((t) => t.id == todo.id);
    if (i != -1) _todos[i] = todo;
    _controller.add(List.unmodifiable(_todos));
  }

  @override
  Future<void> remove(String id) async {
    _todos.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_todos));
  }

  @override
  Future<void> close() async => _controller.close();
}

// ─── Test app builder ─────────────────────────────────────────────────────────

Widget buildTestApp() {
  final settings = SettingsNotifier();

  final auth = AuthRepository();
  auth.continueOffline();

  final listRepo = ListRepository();
  // Directly set up local mode without hitting SharedPreferences
  listRepo.init(null);

  final todoRepo = TodoRepository();
  todoRepo.attachSource(_MemoryTodoSource());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: listRepo),
      ChangeNotifierProvider.value(value: todoRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.buildLight(settings.colorProfile),
      darkTheme: AppTheme.buildDark(settings.colorProfile),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const TodoListScreen(),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Todo list screen shows list name in title', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(TodoList.local.name), findsOneWidget);
  });

  testWidgets('Todo list screen shows filter tabs', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('All'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Empty state shown when there are no tasks', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('No tasks yet.\nTap + to add your first task.'),
      findsOneWidget,
    );
  });

  testWidgets('Bottom navigation bar has Tasks, Calendar and Settings tabs', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Tapping Settings tab shows settings screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    await tester.tap(find.text('Settings').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('APPEARANCE'), findsOneWidget);
  });

  testWidgets('FAB opens new task screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Task title *'), findsOneWidget);
  });

  testWidgets('Search toggle shows search bar', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets('Sort button opens sort bottom sheet', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.sort_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Priority'), findsWidgets);
    expect(find.text('Due Date'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/features/todos/data/todo_repository.dart';
import 'package:starter_app/features/todos/presentation/screens/todo_list_screen.dart';

Widget _testApp() {
  final settings = SettingsNotifier();
  final todos = TodoRepository();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: todos),
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

void main() {
  testWidgets('Todo list screen shows "My Tasks" title', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
  });

  testWidgets('Todo list screen shows filter tabs', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('All'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Empty state is shown when there are no tasks', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(
      find.text('No tasks yet.\nTap + to add your first task.'),
      findsOneWidget,
    );
  });

  testWidgets('Bottom navigation bar has Tasks and Settings tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Tapping Settings tab shows settings screen', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
  });

  testWidgets('FAB opens new task screen', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Task title *'), findsOneWidget);
  });
}

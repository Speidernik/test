import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_theme.dart';
import 'package:starter_app/core/l10n/app_strings.dart';
import 'package:starter_app/features/auth/presentation/screens/login_screen.dart';

Widget _testApp() {
  final settings = SettingsNotifier();
  return ChangeNotifierProvider.value(
    value: settings,
    child: MaterialApp(
      theme: AppTheme.buildLight(settings.colorProfile),
      darkTheme: AppTheme.buildDark(settings.colorProfile),
      locale: const Locale('en'),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('Login screen renders sign-in button', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('SIGN IN'), findsOneWidget);
  });

  testWidgets('Login screen shows email and password fields', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsAtLeast(2));
  });
}

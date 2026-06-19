import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/auth/auth_repository.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/color_profiles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final auth = context.watch<AuthRepository>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader('Appearance'),
          _ThemeTile(settings: settings),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ColorProfileTile(settings: settings),
          const SizedBox(height: 24),
          _SectionHeader('Account'),
          if (auth.isLoggedIn)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  auth.user!.initials,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(auth.user!.displayName),
              subtitle: Text(
                auth.user!.email,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ListTile(
            leading: Icon(
              auth.isLoggedIn ? Icons.logout_outlined : Icons.login_outlined,
              color: auth.isLoggedIn ? theme.colorScheme.error : null,
            ),
            title: Text(
              auth.isLoggedIn
                  ? 'Sign out'
                  : auth.isOffline
                  ? 'Sign in'
                  : 'Sign in / Sign up',
            ),
            textColor: auth.isLoggedIn ? theme.colorScheme.error : null,
            onTap: () => auth.signOut(),
          ),
          const SizedBox(height: 24),
          _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('Todo Template'),
            subtitle: const Text('v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('Built with Flutter'),
            subtitle: Text(
              'Material Design 3  ·  Provider  ·  SharedPreferences',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final SettingsNotifier settings;
  const _ThemeTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: const Text('Theme'),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined, size: 18),
            label: Text('Light'),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined, size: 18),
            label: Text('Auto'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined, size: 18),
            label: Text('Dark'),
          ),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (s) => settings.setThemeMode(s.first),
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }
}

class _ColorProfileTile extends StatelessWidget {
  final SettingsNotifier settings;
  const _ColorProfileTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Color Profile'),
      subtitle: Text(settings.colorProfile.label),
      children: [
        RadioGroup<ColorProfile>(
          groupValue: settings.colorProfile,
          onChanged: (v) {
            if (v != null) settings.setColorProfile(v);
          },
          child: Column(
            children: ColorProfile.values
                .map(
                  (p) => RadioListTile<ColorProfile>(
                    title: Text(p.label),
                    value: p,
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

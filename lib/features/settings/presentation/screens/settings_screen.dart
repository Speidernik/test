import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/core/theme/color_profiles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final s = settings.strings;
    final isDark = settings.isDark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Row(
            children: [
              _iconBox(Icons.settings_rounded),
              const SizedBox(width: 10),
              Text(s.settings,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 1)),
            ],
          ),
          pinned: true,
          floating: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Appearance ──────────────────────────────────────────────
              _SectionHeader(s.appearance),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  // Dark mode toggle
                  _SwitchTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: s.darkMode,
                    value: isDark,
                    onChanged: (_) => settings.toggleTheme(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Language ─────────────────────────────────────────────────
              _SectionHeader(s.language),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _RadioTile<AppLanguage>(
                    icon: Icons.language_rounded,
                    title: s.langEnglish,
                    value: AppLanguage.english,
                    groupValue: settings.language,
                    onChanged: settings.setLanguage,
                  ),
                  _Divider(isDark: isDark),
                  _RadioTile<AppLanguage>(
                    icon: Icons.language_rounded,
                    title: s.langGerman,
                    value: AppLanguage.german,
                    groupValue: settings.language,
                    onChanged: settings.setLanguage,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Color Profile ─────────────────────────────────────────────
              _SectionHeader(s.colorProfile),
              const SizedBox(height: 4),
              Text(
                s.colorProfileHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  for (final (i, profile) in ColorProfile.values.indexed) ...[
                    _ColorProfileTile(
                      profile: profile,
                      isSelected: settings.colorProfile == profile,
                      isGerman: settings.language == AppLanguage.german,
                      onTap: () => settings.setColorProfile(profile),
                    ),
                    if (i < ColorProfile.values.length - 1)
                      _Divider(isDark: isDark),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // ── Scanner Info ───────────────────────────────────────────────
              _SectionHeader(s.scanner),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded,
                            color: AppColors.amber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zebra DataWedge',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.scannerHint,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── About ──────────────────────────────────────────────────────
              _SectionHeader(s.about),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _InfoTile(
                    icon: Icons.warehouse_rounded,
                    title: s.appName,
                    subtitle: '${s.version} 1.0.0',
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.amber,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      );
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.5,
              color: AppColors.amber,
              fontSize: 11,
            ),
      );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 52,
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Switch(
              value: value,
              activeThumbColor: AppColors.amber,
              activeTrackColor: AppColors.amber.withAlpha(77),
              onChanged: onChanged,
            ),
          ],
        ),
      );
}

class _RadioTile<T> extends StatelessWidget {
  const _RadioTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final T value;
  final T groupValue;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ),
              Icon(
                value == groupValue
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: value == groupValue
                    ? AppColors.amber
                    : AppColors.darkBorder,
                size: 22,
              ),
            ],
          ),
        ),
      );
}

class _ColorProfileTile extends StatelessWidget {
  const _ColorProfileTile({
    required this.profile,
    required this.isSelected,
    required this.isGerman,
    required this.onTap,
  });
  final ColorProfile profile;
  final bool isSelected;
  final bool isGerman;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = profileColors(profile);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Color swatch preview
            Row(
              children: [
                _Swatch(colors.success),
                const SizedBox(width: 4),
                _Swatch(colors.error),
                const SizedBox(width: 4),
                _Swatch(colors.primary),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isGerman ? profile.labelDe : profile.label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.amber, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(51), width: 1),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.amber, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      );
}

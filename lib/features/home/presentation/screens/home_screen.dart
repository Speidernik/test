import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:starter_app/features/picking/presentation/screens/picking_list_screen.dart';
import 'package:starter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:starter_app/features/stock_movement/presentation/screens/stock_movement_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _DashboardTab(),
    StockMovementListScreen(),
    PickingListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsNotifier>().strings;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: s.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz_rounded),
            label: s.stockMovements,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist_rounded),
            label: s.picking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: s.settings,
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Tab ─────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warehouse_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'WAREHOUSE PRO',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 16),
              ),
            ],
          ),
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              onPressed: settings.toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: s.signOut,
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _WelcomeBanner(s: s, isDark: isDark),
              const SizedBox(height: 24),
              Text(
                s.overview.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.amber,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    icon: Icons.inventory_2_rounded,
                    label: s.itemsInStock,
                    value: '12,480',
                    color: AppColors.amber,
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Icons.local_shipping_rounded,
                    label: s.ordersToday,
                    value: '348',
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: s.pendingPicks,
                    value: '57',
                    color: const Color(0xFF6366F1),
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: Icons.warning_amber_rounded,
                    label: s.lowStockAlerts,
                    value: '9',
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                s.recentActivity.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.amber,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: 12),
              _ActivityList(isDark: isDark),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.s, required this.isDark});
  final dynamic s;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.amberLight, AppColors.amberDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber.withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.goodMorning,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.warehouseRunning,
                    style: TextStyle(
                        color: Colors.white.withAlpha(204), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 40),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      );
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.isDark});
  final bool isDark;

  static const _items = [
    _ActivityItem(
      icon: Icons.add_box_rounded,
      color: AppColors.success,
      title: 'Stock received — Zone B',
      subtitle: '240 units · Shelf 3B-12',
      time: '10 min ago',
    ),
    _ActivityItem(
      icon: Icons.local_shipping_rounded,
      color: AppColors.amber,
      title: 'Order #8821 dispatched',
      subtitle: 'Carrier: DHL · 14 packages',
      time: '32 min ago',
    ),
    _ActivityItem(
      icon: Icons.warning_amber_rounded,
      color: AppColors.error,
      title: 'Low stock alert — SKU-4421',
      subtitle: 'Only 3 units remaining',
      time: '1 hr ago',
    ),
    _ActivityItem(
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF6366F1),
      title: 'Transfer completed — Zone A→C',
      subtitle: '80 pallets moved',
      time: '2 hr ago',
    ),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: _items
              .asMap()
              .entries
              .map((e) => Column(
                    children: [
                      _ActivityTile(item: e.value),
                      if (e.key < _items.length - 1)
                        Divider(
                          height: 1,
                          indent: 60,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                    ],
                  ))
              .toList(),
        ),
      );
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(item.time,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11)),
          ],
        ),
      );
}

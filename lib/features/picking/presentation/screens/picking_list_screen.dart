import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/features/picking/data/models/picking_list_model.dart';
import 'package:starter_app/features/picking/data/picking_repository.dart';
import 'package:starter_app/features/picking/presentation/screens/picking_screen.dart';

class PickingListScreen extends StatefulWidget {
  const PickingListScreen({super.key});

  @override
  State<PickingListScreen> createState() => _PickingListScreenState();
}

class _PickingListScreenState extends State<PickingListScreen> {
  final _repo = PickingRepository();
  List<PickingList>? _lists;
  PickingStatus? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getLists();
    if (mounted) setState(() => _lists = data);
  }

  List<PickingList> get _filtered {
    final list = _lists ?? [];
    if (_filter == null) return list;
    return list.where((l) => l.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsNotifier>().strings;
    final isDark = context.watch<SettingsNotifier>().isDark;
    final isGerman =
        context.watch<SettingsNotifier>().language == AppLanguage.german;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Row(
            children: [
              _iconBox(Icons.checklist_rounded),
              const SizedBox(width: 10),
              Text(
                s.picking,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pinned: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: _FilterBar(
              current: _filter,
              isDark: isDark,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
        ),
        if (_lists == null)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                s.noData,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final list = _filtered[i];
                return _PickingCard(
                  list: list,
                  isDark: isDark,
                  isGerman: isGerman,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PickingScreen(listId: list.id),
                      ),
                    );
                    _load();
                  },
                );
              },
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

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.current,
    required this.isDark,
    required this.onChanged,
  });
  final PickingStatus? current;
  final bool isDark;
  final void Function(PickingStatus?) onChanged;

  @override
  Widget build(BuildContext context) => Container(
    color: isDark ? AppColors.darkSurface : Colors.white,
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: current == null,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Open',
            selected: current == PickingStatus.open,
            onTap: () => onChanged(PickingStatus.open),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'In Progress',
            selected: current == PickingStatus.inProgress,
            onTap: () => onChanged(PickingStatus.inProgress),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Completed',
            selected: current == PickingStatus.completed,
            onTap: () => onChanged(PickingStatus.completed),
          ),
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.amber : AppColors.darkBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    ),
  );
}

class _PickingCard extends StatelessWidget {
  const _PickingCard({
    required this.list,
    required this.isDark,
    required this.isGerman,
    required this.onTap,
  });
  final PickingList list;
  final bool isDark;
  final bool isGerman;
  final VoidCallback onTap;

  Color get _statusColor => switch (list.status) {
    PickingStatus.open => AppColors.warning,
    PickingStatus.inProgress => const Color(0xFF6366F1),
    PickingStatus.completed => AppColors.success,
  };

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.id,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    list.orderId,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.amber),
                  ),
                ],
              ),
              const Spacer(),
              _StatusBadge(
                label: list.status.label(isGerman),
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.business_rounded,
                size: 14,
                color: AppColors.darkTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(list.customer, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '${list.pickedCount}/${list.items.length} items',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (list.status != PickingStatus.completed) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: list.progress,
                minHeight: 4,
                backgroundColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.amber,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(26),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(77)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

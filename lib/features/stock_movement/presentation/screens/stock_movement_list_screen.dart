import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/features/stock_movement/data/models/stock_movement.dart';
import 'package:starter_app/features/stock_movement/data/stock_movement_repository.dart';
import 'package:starter_app/features/stock_movement/presentation/screens/stock_movement_detail_screen.dart';

class StockMovementListScreen extends StatefulWidget {
  const StockMovementListScreen({super.key});

  @override
  State<StockMovementListScreen> createState() =>
      _StockMovementListScreenState();
}

class _StockMovementListScreenState extends State<StockMovementListScreen> {
  final _repo = StockMovementRepository();
  List<StockMovement>? _movements;
  MovementStatus? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _repo.getMovements();
    if (mounted) setState(() => _movements = data);
  }

  List<StockMovement> get _filtered {
    final list = _movements ?? [];
    if (_filter == null) return list;
    return list.where((m) => m.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsNotifier>().strings;
    final isDark = context.watch<SettingsNotifier>().isDark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Row(
            children: [
              _iconBox(Icons.swap_horiz_rounded),
              const SizedBox(width: 10),
              Text(s.stockMovements,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
        if (_movements == null)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(s.noData,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = _filtered[i];
                return _MovementCard(
                  movement: m,
                  isDark: isDark,
                  isGerman: context.watch<SettingsNotifier>().language ==
                      AppLanguage.german,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            StockMovementDetailScreen(movementId: m.id),
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
  final MovementStatus? current;
  final bool isDark;
  final void Function(MovementStatus?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(label: 'All', selected: current == null,
                onTap: () => onChanged(null)),
            const SizedBox(width: 8),
            _Chip(label: 'Pending', selected: current == MovementStatus.pending,
                onTap: () => onChanged(MovementStatus.pending)),
            const SizedBox(width: 8),
            _Chip(label: 'In Progress',
                selected: current == MovementStatus.inProgress,
                onTap: () => onChanged(MovementStatus.inProgress)),
            const SizedBox(width: 8),
            _Chip(label: 'Completed',
                selected: current == MovementStatus.completed,
                onTap: () => onChanged(MovementStatus.completed)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
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

class _MovementCard extends StatelessWidget {
  const _MovementCard({
    required this.movement,
    required this.isDark,
    required this.isGerman,
    required this.onTap,
  });
  final StockMovement movement;
  final bool isDark;
  final bool isGerman;
  final VoidCallback onTap;

  Color get _statusColor => switch (movement.status) {
        MovementStatus.pending => AppColors.warning,
        MovementStatus.inProgress => const Color(0xFF6366F1),
        MovementStatus.completed => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(movement.id,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                _StatusBadge(
                  label: movement.status.label(isGerman),
                  color: _statusColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LocationRow(
              from: movement.fromLocation,
              to: movement.toLocation,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 4),
                Text(movement.operatorName,
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text(
                  '${movement.confirmedCount}/${movement.items.length} items',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (movement.status != MovementStatus.completed) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: movement.progress,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.amber),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FROM',
                    style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600)),
                Text(from,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded,
                size: 16, color: AppColors.amber),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TO',
                    style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w600)),
                Text(to,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/core/widgets/scanner_input_field.dart';
import 'package:starter_app/features/stock_movement/data/models/stock_movement.dart';
import 'package:starter_app/features/stock_movement/data/stock_movement_repository.dart';

class StockMovementDetailScreen extends StatefulWidget {
  const StockMovementDetailScreen({super.key, required this.movementId});
  final String movementId;

  @override
  State<StockMovementDetailScreen> createState() =>
      _StockMovementDetailScreenState();
}

class _StockMovementDetailScreenState
    extends State<StockMovementDetailScreen> {
  final _repo = StockMovementRepository();
  StockMovement? _movement;
  String? _feedbackMessage;
  bool _feedbackIsError = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _repo.getMovement(widget.movementId);
    if (mounted) setState(() => _movement = m);
  }

  Future<void> _onScan(String barcode) async {
    if (_movement == null) return;
    final s = context.read<SettingsNotifier>().strings;
    final error = await _repo.confirmItem(_movement!.id, barcode);

    if (!mounted) return;
    if (error == null) {
      setState(() {
        _feedbackMessage = s.itemConfirmed;
        _feedbackIsError = false;
      });
    } else if (error == 'already_confirmed') {
      setState(() {
        _feedbackMessage = s.alreadyConfirmed;
        _feedbackIsError = false;
      });
    } else {
      setState(() {
        _feedbackMessage = s.barcodeNotFound;
        _feedbackIsError = true;
      });
    }
    await _load();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  Future<void> _complete() async {
    if (_movement == null || !_movement!.isFullyConfirmed) return;
    setState(() => _completing = true);
    await _repo.completeMovement(_movement!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final s = settings.strings;
    final isDark = settings.isDark;
    final movement = _movement;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movementId,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        leading: const BackButton(),
      ),
      body: movement == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Header info ──────────────────────────────────────────────
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InfoBlock(
                              label: s.from,
                              value: movement.fromLocation,
                              icon: Icons.location_on_rounded,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.amber),
                          Expanded(
                            child: _InfoBlock(
                              label: s.to,
                              value: movement.toLocation,
                              icon: Icons.flag_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${movement.confirmedCount} / ${movement.items.length} ${s.items}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '${(movement.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: movement.progress,
                          minHeight: 6,
                          backgroundColor:
                              isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ── Item list ────────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: movement.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = movement.items[i];
                      return _ItemTile(item: item, isDark: isDark);
                    },
                  ),
                ),

                // ── Feedback message ─────────────────────────────────────────
                if (_feedbackMessage != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    color: _feedbackIsError
                        ? AppColors.error.withAlpha(26)
                        : AppColors.success.withAlpha(26),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          _feedbackIsError
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_rounded,
                          color: _feedbackIsError
                              ? AppColors.error
                              : AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _feedbackMessage!,
                          style: TextStyle(
                            color: _feedbackIsError
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Scanner + action ─────────────────────────────────────────
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: [
                      ScannerInputField(
                        hint: s.scanToConfirm,
                        onScan: _onScan,
                        enabled:
                            movement.status != MovementStatus.completed,
                      ),
                      const SizedBox(height: 12),
                      if (movement.isFullyConfirmed &&
                          movement.status != MovementStatus.completed)
                        _CompleteButton(
                          label: s.completeMovement,
                          isLoading: _completing,
                          onPressed: _complete,
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.amber),
              const SizedBox(width: 4),
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.isDark});
  final StockMovementItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isConfirmed
              ? AppColors.success.withAlpha(20)
              : isDark
                  ? AppColors.darkSurface
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isConfirmed
                ? AppColors.success.withAlpha(77)
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.isConfirmed
                    ? AppColors.success.withAlpha(26)
                    : AppColors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.isConfirmed
                    ? Icons.check_rounded
                    : Icons.inventory_2_rounded,
                color: item.isConfirmed ? AppColors.success : AppColors.amber,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.sku,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                  Text(item.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('× ${item.quantity}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (item.isConfirmed)
                  const Text('✓',
                      style: TextStyle(
                          color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_rounded, color: Colors.white),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      );
}

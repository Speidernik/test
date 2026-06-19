import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_app/core/settings/settings_notifier.dart';
import 'package:starter_app/core/theme/app_colors.dart';
import 'package:starter_app/core/widgets/scanner_input_field.dart';
import 'package:starter_app/features/picking/data/models/picking_list_model.dart';
import 'package:starter_app/features/picking/data/picking_repository.dart';

enum _ScanResult { none, correct, wrong }

class PickingScreen extends StatefulWidget {
  const PickingScreen({super.key, required this.listId});
  final String listId;

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen>
    with TickerProviderStateMixin {
  final _repo = PickingRepository();
  PickingList? _list;
  int _currentIndex = 0;
  _ScanResult _scanResult = _ScanResult.none;
  String? _feedbackMessage;
  bool _completing = false;

  late final AnimationController _flashCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _flashAnim = CurvedAnimation(
    parent: _flashCtrl,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.getList(widget.listId);
    if (!mounted) return;
    setState(() {
      _list = list;
      // Start on first incomplete item
      if (list != null) {
        _currentIndex =
            list.items.indexWhere((i) => !i.isComplete).clamp(0, list.items.length - 1);
      }
    });
  }

  PickingItem? get _currentItem {
    final list = _list;
    if (list == null || list.items.isEmpty) return null;
    return list.items[_currentIndex];
  }

  Future<void> _onScan(String barcode) async {
    final list = _list;
    final item = _currentItem;
    if (list == null || item == null) return;
    final s = context.read<SettingsNotifier>().strings;

    final error = await _repo.scanItem(list.id, barcode);
    await _load();

    if (!mounted) return;

    if (error == null) {
      setState(() {
        _scanResult = _ScanResult.correct;
        _feedbackMessage = s.correctScan;
      });
      _flashCtrl.forward(from: 0);
      // Auto-advance to next incomplete item after a short pause
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        final updatedList = _list;
        if (updatedList == null) return;
        final nextIdx =
            updatedList.items.indexWhere((i) => !i.isComplete);
        setState(() {
          _scanResult = _ScanResult.none;
          _feedbackMessage = null;
          if (nextIdx != -1) _currentIndex = nextIdx;
        });
      });
    } else {
      setState(() {
        _scanResult = _ScanResult.wrong;
        _feedbackMessage = s.wrongBarcode;
      });
      _flashCtrl.forward(from: 0);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _scanResult = _ScanResult.none;
            _feedbackMessage = null;
          });
        }
      });
    }
  }

  Future<void> _complete() async {
    final list = _list;
    if (list == null || !list.isComplete) return;
    setState(() => _completing = true);
    await _repo.completeList(list.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _goTo(int index) {
    final list = _list;
    if (list == null) return;
    setState(() {
      _currentIndex = index.clamp(0, list.items.length - 1);
      _scanResult = _ScanResult.none;
      _feedbackMessage = null;
    });
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();
    final s = settings.strings;
    final isDark = settings.isDark;
    final list = _list;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          list == null ? widget.listId : '${list.orderId} · ${list.customer}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        leading: const BackButton(),
      ),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Overall progress ──────────────────────────────────────
                _ProgressHeader(list: list, isDark: isDark),

                // ── Item navigation strip ────────────────────────────────
                _ItemStrip(
                  items: list.items,
                  currentIndex: _currentIndex,
                  isDark: isDark,
                  onTap: _goTo,
                ),

                // ── Current item card ─────────────────────────────────────
                Expanded(
                  child: _currentItem == null
                      ? Center(child: Text(s.noData))
                      : _CurrentItemCard(
                          item: _currentItem!,
                          index: _currentIndex,
                          total: list.items.length,
                          isDark: isDark,
                          scanResult: _scanResult,
                          flashAnim: _flashAnim,
                          s: s,
                        ),
                ),

                // ── Feedback ──────────────────────────────────────────────
                if (_feedbackMessage != null)
                  _FeedbackBanner(
                    message: _feedbackMessage!,
                    isError: _scanResult == _ScanResult.wrong,
                  ),

                // ── Scanner + nav buttons ─────────────────────────────────
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: [
                      if (!list.isComplete) ...[
                        ScannerInputField(
                          hint: s.scanItem,
                          onScan: _onScan,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentIndex > 0
                                    ? () => _goTo(_currentIndex - 1)
                                    : null,
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 16),
                                label: Text(s.prevItem),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.darkBorder),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentIndex <
                                        list.items.length - 1
                                    ? () => _goTo(_currentIndex + 1)
                                    : null,
                                icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16),
                                label: Text(s.nextItem),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.darkBorder),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (list.isComplete) ...[
                        _CompleteButton(
                          label: s.completePicking,
                          isLoading: _completing,
                          onPressed: _complete,
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.list, required this.isDark});
  final PickingList list;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
        color: isDark ? AppColors.darkSurface : Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${list.pickedCount} / ${list.items.length} items picked',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${(list.progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: list.progress,
                minHeight: 6,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.amber),
              ),
            ),
          ],
        ),
      );
}

class _ItemStrip extends StatelessWidget {
  const _ItemStrip({
    required this.items,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });
  final List<PickingItem> items;
  final int currentIndex;
  final bool isDark;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        color: isDark ? AppColors.darkBg : AppColors.lightBgStart,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, i) {
            final item = items[i];
            final isActive = i == currentIndex;
            Color color;
            if (item.isComplete) {
              color = AppColors.success;
            } else if (isActive) {
              color = AppColors.amber;
            } else {
              color = isDark ? AppColors.darkBorder : AppColors.lightBorder;
            }

            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(isActive ? 255 : 51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: isActive ? 2 : 1),
                ),
                child: Center(
                  child: item.isComplete
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : color,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      );
}

class _CurrentItemCard extends StatelessWidget {
  const _CurrentItemCard({
    required this.item,
    required this.index,
    required this.total,
    required this.isDark,
    required this.scanResult,
    required this.flashAnim,
    required this.s,
  });
  final PickingItem item;
  final int index;
  final int total;
  final bool isDark;
  final _ScanResult scanResult;
  final Animation<double> flashAnim;
  final dynamic s;

  Color get _flashColor => switch (scanResult) {
        _ScanResult.correct => AppColors.success,
        _ScanResult.wrong => AppColors.error,
        _ScanResult.none => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: scanResult == _ScanResult.none
            ? const AlwaysStoppedAnimation(1.0)
            : Tween<double>(begin: 1, end: 1).animate(flashAnim),
        child: AnimatedBuilder(
          animation: flashAnim,
          builder: (context, child) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scanResult != _ScanResult.none
                  ? _flashColor.withAlpha(
                      (26 * (1 - flashAnim.value)).toInt())
                  : (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scanResult != _ScanResult.none
                    ? _flashColor.withAlpha(
                        (180 * (1 - flashAnim.value)).toInt())
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: scanResult != _ScanResult.none ? 2 : 1,
              ),
            ),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item counter
                Text(
                  'ITEM ${index + 1} OF $total',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppColors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Location (most important on screen) ───────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.amber.withAlpha(77)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LOCATION',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.5,
                                color: AppColors.amber.withAlpha(179),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── SKU + Description ──────────────────────────────────────
                Text(
                  item.sku,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                ),
                const Spacer(),

                // ── Quantity ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: AppColors.amber,
                            height: 1,
                          ),
                        ),
                        Text(
                          'UNITS TO PICK',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (item.pickedQuantity > 0 &&
                        item.pickedQuantity < item.quantity) ...[
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            '${item.pickedQuantity}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'PICKED',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 2,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                if (item.isComplete) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'DONE',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        color: isError
            ? AppColors.error.withAlpha(26)
            : AppColors.success.withAlpha(26),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: isError ? AppColors.error : AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton(
      {required this.label,
      required this.isLoading,
      required this.onPressed});
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle_rounded,
                  color: Colors.white),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      );
}

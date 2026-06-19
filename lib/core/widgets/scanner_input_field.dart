import 'dart:async';
import 'package:flutter/material.dart';
import 'package:starter_app/core/scanner/scanner_service.dart';
import 'package:starter_app/core/theme/app_colors.dart';

/// Handles both Zebra DataWedge intent scans and manual keyboard/text entry.
/// Subscribe to [onScan] for barcode results regardless of input source.
class ScannerInputField extends StatefulWidget {
  const ScannerInputField({
    super.key,
    required this.onScan,
    this.hint = 'Scan barcode or type manually',
    this.enabled = true,
    this.autoFocus = true,
  });

  final void Function(String barcode) onScan;
  final String hint;
  final bool enabled;
  final bool autoFocus;

  @override
  State<ScannerInputField> createState() => _ScannerInputFieldState();
}

class _ScannerInputFieldState extends State<ScannerInputField>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  StreamSubscription<String>? _scanSub;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _scanSub = ScannerService.instance.scanStream.listen(_onDataWedgeScan);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _onDataWedgeScan(String barcode) {
    if (!widget.enabled || !mounted) return;
    widget.onScan(barcode.trim());
  }

  void _submitManual() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    _controller.clear();
    widget.onScan(value);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _pulseCtrl.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scan animation indicator
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) => Opacity(
            opacity: widget.enabled ? _pulseAnim.value : 0.2,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.amber,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitManual(),
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  prefixIcon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.amber,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: widget.enabled ? _submitManual : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.check_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:starter_app/features/stock_movement/data/models/stock_movement.dart';

class StockMovementRepository {
  // In a real app this would call your backend / WMS API
  final List<StockMovement> _movements = [
    StockMovement(
      id: 'SM-2024-001',
      fromLocation: 'Zone A / Row 3 / Shelf 2',
      toLocation: 'Zone C / Row 1 / Shelf 4',
      status: MovementStatus.pending,
      date: DateTime.now().subtract(const Duration(minutes: 30)),
      operatorName: 'Max Müller',
      items: [
        StockMovementItem(
          id: 'i1',
          sku: 'SKU-4421',
          description: 'Blue Widget Box 500ml',
          quantity: 24,
          barcode: 'BC4421001',
        ),
        StockMovementItem(
          id: 'i2',
          sku: 'SKU-8832',
          description: 'Red Container 1L',
          quantity: 12,
          barcode: 'BC8832002',
        ),
        StockMovementItem(
          id: 'i3',
          sku: 'SKU-1156',
          description: 'Yellow Drum 5L',
          quantity: 6,
          barcode: 'BC1156003',
        ),
      ],
    ),
    StockMovement(
      id: 'SM-2024-002',
      fromLocation: 'Receiving Dock B',
      toLocation: 'Zone B / Row 2 / Shelf 1',
      status: MovementStatus.inProgress,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      operatorName: 'Anna Schmidt',
      items: [
        StockMovementItem(
          id: 'i4',
          sku: 'SKU-3310',
          description: 'Cardboard Box Large',
          quantity: 48,
          barcode: 'BC3310004',
        ),
        StockMovementItem(
          id: 'i5',
          sku: 'SKU-7790',
          description: 'Foam Packing Sheet',
          quantity: 100,
          barcode: 'BC7790005',
        ),
      ],
    ),
    StockMovement(
      id: 'SM-2024-003',
      fromLocation: 'Zone D / Row 5 / Shelf 3',
      toLocation: 'Shipping Dock A',
      status: MovementStatus.completed,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      operatorName: 'Tom Weber',
      items: [
        StockMovementItem(
          id: 'i6',
          sku: 'SKU-9901',
          description: 'Plastic Pallet 120x80',
          quantity: 4,
          barcode: 'BC9901006',
          isConfirmed: true,
          scannedBarcode: 'BC9901006',
        ),
      ],
    ),
    StockMovement(
      id: 'SM-2024-004',
      fromLocation: 'Zone B / Row 1 / Shelf 5',
      toLocation: 'Zone A / Row 4 / Shelf 1',
      status: MovementStatus.pending,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      operatorName: 'Max Müller',
      items: [
        StockMovementItem(
          id: 'i7',
          sku: 'SKU-2245',
          description: 'Glass Bottle 750ml',
          quantity: 60,
          barcode: 'BC2245007',
        ),
        StockMovementItem(
          id: 'i8',
          sku: 'SKU-6612',
          description: 'Cork Stopper Set (100)',
          quantity: 3,
          barcode: 'BC6612008',
        ),
        StockMovementItem(
          id: 'i9',
          sku: 'SKU-5501',
          description: 'Label Roll A4',
          quantity: 10,
          barcode: 'BC5501009',
        ),
        StockMovementItem(
          id: 'i10',
          sku: 'SKU-3388',
          description: 'Shrink Wrap 500m',
          quantity: 5,
          barcode: 'BC3388010',
        ),
      ],
    ),
  ];

  Future<List<StockMovement>> getMovements() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_movements);
  }

  Future<StockMovement?> getMovement(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _movements.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns null on success, or error message string on failure.
  Future<String?> confirmItem(String movementId, String barcode) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final movement = _movements.firstWhere(
      (m) => m.id == movementId,
      orElse: () => throw StateError('Movement not found'),
    );

    try {
      final item = movement.items.firstWhere(
        (i) => i.barcode == barcode.trim(),
      );
      if (item.isConfirmed) return 'already_confirmed';
      item.isConfirmed = true;
      item.scannedBarcode = barcode;
      return null;
    } catch (_) {
      return 'not_found';
    }
  }

  Future<void> completeMovement(String movementId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _movements.indexWhere((m) => m.id == movementId);
    if (idx == -1) return;
    final m = _movements[idx];
    _movements[idx] = StockMovement(
      id: m.id,
      fromLocation: m.fromLocation,
      toLocation: m.toLocation,
      status: MovementStatus.completed,
      date: m.date,
      operatorName: m.operatorName,
      items: m.items,
    );
  }
}

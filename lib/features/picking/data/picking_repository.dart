import 'package:starter_app/features/picking/data/models/picking_list_model.dart';

class PickingRepository {
  final List<PickingList> _lists = [
    PickingList(
      id: 'PL-2024-001',
      orderId: 'ORD-88210',
      customer: 'Acme GmbH',
      status: PickingStatus.open,
      date: DateTime.now().subtract(const Duration(minutes: 10)),
      items: [
        PickingItem(
          id: 'p1', sku: 'SKU-4421',
          description: 'Blue Widget Box 500ml',
          location: 'Zone A / Row 3 / Shelf 2',
          quantity: 6, barcode: 'BC4421001',
        ),
        PickingItem(
          id: 'p2', sku: 'SKU-8832',
          description: 'Red Container 1L',
          location: 'Zone A / Row 3 / Shelf 4',
          quantity: 2, barcode: 'BC8832002',
        ),
        PickingItem(
          id: 'p3', sku: 'SKU-7790',
          description: 'Foam Packing Sheet',
          location: 'Zone B / Row 2 / Shelf 1',
          quantity: 10, barcode: 'BC7790005',
        ),
      ],
    ),
    PickingList(
      id: 'PL-2024-002',
      orderId: 'ORD-88214',
      customer: 'TechBox AG',
      status: PickingStatus.inProgress,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      items: [
        PickingItem(
          id: 'p4', sku: 'SKU-9901',
          description: 'Plastic Pallet 120x80',
          location: 'Zone D / Row 5 / Shelf 3',
          quantity: 2, barcode: 'BC9901006',
          pickedQuantity: 1,
        ),
        PickingItem(
          id: 'p5', sku: 'SKU-2245',
          description: 'Glass Bottle 750ml',
          location: 'Zone B / Row 1 / Shelf 5',
          quantity: 12, barcode: 'BC2245007',
        ),
        PickingItem(
          id: 'p6', sku: 'SKU-3310',
          description: 'Cardboard Box Large',
          location: 'Zone B / Row 2 / Shelf 1',
          quantity: 8, barcode: 'BC3310004',
        ),
        PickingItem(
          id: 'p7', sku: 'SKU-6612',
          description: 'Cork Stopper Set (100)',
          location: 'Zone C / Row 1 / Shelf 4',
          quantity: 1, barcode: 'BC6612008',
        ),
      ],
    ),
    PickingList(
      id: 'PL-2024-003',
      orderId: 'ORD-88198',
      customer: 'Müller & Co.',
      status: PickingStatus.completed,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      items: [
        PickingItem(
          id: 'p8', sku: 'SKU-5501',
          description: 'Label Roll A4',
          location: 'Zone A / Row 4 / Shelf 1',
          quantity: 3, barcode: 'BC5501009',
          pickedQuantity: 3,
        ),
      ],
    ),
    PickingList(
      id: 'PL-2024-004',
      orderId: 'ORD-88221',
      customer: 'Logistics Express',
      status: PickingStatus.open,
      date: DateTime.now().subtract(const Duration(minutes: 5)),
      items: [
        PickingItem(
          id: 'p9', sku: 'SKU-1156',
          description: 'Yellow Drum 5L',
          location: 'Zone C / Row 3 / Shelf 2',
          quantity: 4, barcode: 'BC1156003',
        ),
        PickingItem(
          id: 'p10', sku: 'SKU-3388',
          description: 'Shrink Wrap 500m',
          location: 'Zone D / Row 1 / Shelf 3',
          quantity: 2, barcode: 'BC3388010',
        ),
      ],
    ),
  ];

  Future<List<PickingList>> getLists() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_lists);
  }

  Future<PickingList?> getList(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns null on success, or an error key ('not_found' / 'already_picked').
  Future<String?> scanItem(String listId, String barcode) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = _lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => throw StateError('Picking list not found'),
    );
    try {
      final item = list.items.firstWhere(
        (i) => i.barcode == barcode.trim(),
      );
      if (item.isComplete) return 'already_picked';
      item.pickedQuantity++;
      return null;
    } catch (_) {
      return 'not_found';
    }
  }

  Future<void> completeList(String listId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _lists.indexWhere((l) => l.id == listId);
    if (idx == -1) return;
    final l = _lists[idx];
    _lists[idx] = PickingList(
      id: l.id,
      orderId: l.orderId,
      customer: l.customer,
      status: PickingStatus.completed,
      date: l.date,
      items: l.items,
    );
  }
}

enum PickingStatus { open, inProgress, completed }

extension PickingStatusLabel on PickingStatus {
  String label(bool de) => switch (this) {
    PickingStatus.open => de ? 'Offen' : 'Open',
    PickingStatus.inProgress => de ? 'In Bearbeitung' : 'In Progress',
    PickingStatus.completed => de ? 'Abgeschlossen' : 'Completed',
  };
}

class PickingList {
  final String id;
  final String orderId;
  final String customer;
  final PickingStatus status;
  final DateTime date;
  final List<PickingItem> items;

  PickingList({
    required this.id,
    required this.orderId,
    required this.customer,
    required this.status,
    required this.date,
    required this.items,
  });

  int get pickedCount => items.where((i) => i.isComplete).length;
  bool get isComplete => pickedCount == items.length;
  double get progress => items.isEmpty ? 0 : pickedCount / items.length;
}

class PickingItem {
  final String id;
  final String sku;
  final String description;
  final String location;
  final int quantity;
  final String barcode;
  int pickedQuantity;

  PickingItem({
    required this.id,
    required this.sku,
    required this.description,
    required this.location,
    required this.quantity,
    required this.barcode,
    this.pickedQuantity = 0,
  });

  bool get isComplete => pickedQuantity >= quantity;
}

enum MovementStatus { pending, inProgress, completed }

extension MovementStatusLabel on MovementStatus {
  String label(bool de) => switch (this) {
        MovementStatus.pending => de ? 'Ausstehend' : 'Pending',
        MovementStatus.inProgress => de ? 'In Bearbeitung' : 'In Progress',
        MovementStatus.completed => de ? 'Abgeschlossen' : 'Completed',
      };
}

class StockMovement {
  final String id;
  final String fromLocation;
  final String toLocation;
  final MovementStatus status;
  final DateTime date;
  final String operatorName;
  final List<StockMovementItem> items;

  StockMovement({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.status,
    required this.date,
    required this.operatorName,
    required this.items,
  });

  int get confirmedCount => items.where((i) => i.isConfirmed).length;
  bool get isFullyConfirmed => confirmedCount == items.length;
  double get progress =>
      items.isEmpty ? 0 : confirmedCount / items.length;
}

class StockMovementItem {
  final String id;
  final String sku;
  final String description;
  final int quantity;
  final String barcode;
  bool isConfirmed;
  String? scannedBarcode;

  StockMovementItem({
    required this.id,
    required this.sku,
    required this.description,
    required this.quantity,
    required this.barcode,
    this.isConfirmed = false,
    this.scannedBarcode,
  });
}

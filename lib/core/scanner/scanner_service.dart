import 'package:flutter/services.dart';

// DataWedge setup on the Zebra device:
// 1. Open DataWedge → Create/edit a profile for this app (com.example.starter_app)
// 2. Enable "Intent output"
// 3. Intent action: com.starter_app.ACTION_SCAN
// 4. Intent delivery: Broadcast intent
// 5. The barcode value arrives in extra key: com.symbol.datawedge.data_string
class ScannerService {
  ScannerService._();
  static final ScannerService instance = ScannerService._();

  static const _channel = EventChannel('com.example.starter_app/scanner');

  late final Stream<String> scanStream = _channel
      .receiveBroadcastStream()
      .map((e) => e.toString())
      .asBroadcastStream();
}

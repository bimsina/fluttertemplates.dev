import 'dart:async';

/// The seam between the register and whatever reads barcodes.
///
/// The register only listens to [scans]. To use real hardware, implement this
/// interface and pass it to `RetailPosApp(scanner: ...)`:
///
/// * USB or Bluetooth wedge scanners type digits and a newline. Collect them
///   with `HardwareKeyboard.instance.addHandler` and add each finished code
///   to [scans].
/// * For a camera, wrap a package such as `mobile_scanner` and forward its
///   detections, de-duplicating repeats of the same code.
/// * For a device with a built-in imager, forward its platform channel events.
abstract interface class BarcodeScanner {
  /// Shown beside the scan field, for example `USB scanner`.
  String get name;

  /// Emits one value for each code read.
  Stream<String> get scans;

  /// Called when the register is ready to accept scans.
  Future<void> start();

  /// Called while taking payment, so a stray scan cannot change the order.
  Future<void> stop();

  /// A code keyed by hand. Real scanners keep this too, for damaged labels.
  void enterManually(String code);

  void dispose();
}

/// The default implementation: no hardware, the scan field is the input.
class ManualBarcodeScanner implements BarcodeScanner {
  final _controller = StreamController<String>.broadcast();
  bool _active = false;

  @override
  String get name => 'Manual entry';

  @override
  Stream<String> get scans => _controller.stream;

  @override
  Future<void> start() async => _active = true;

  @override
  Future<void> stop() async => _active = false;

  @override
  void enterManually(String code) {
    final trimmed = code.trim();
    if (_active && trimmed.isNotEmpty) _controller.add(trimmed);
  }

  @override
  void dispose() => _controller.close();
}

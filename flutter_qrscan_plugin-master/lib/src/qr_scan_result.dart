import 'dart:math';

///
enum QrScanSource { camera, gallery }

class QrScanResult {
  final String? barcodeFormat;
  final String? text;
  final List<Point<double>>? points;

  const QrScanResult({
    this.barcodeFormat,
    this.text,
    this.points,
  });

  double? get centerX => points?.getCenter((point) => point.x);

  double? get centerY => points?.getCenter((point) => point.y);

  @override
  String toString() {
    return 'QRScanResult{barcodeFormat: $barcodeFormat, text: $text, points: $points}';
  }
}

extension _PointsExt on List<Point<double>> {
  double? getCenter(double Function(Point<double> point) toDouble) {
    if (isEmpty) {
      return null;
    }
    if (length == 1) {
      return toDouble(first);
    }
    var min_ = toDouble(this[0]);
    var max_ = toDouble(this[0]);
    for (var point in this) {
      min_ = min(min_, toDouble(point));
      max_ = max(max_, toDouble(point));
    }
    return ((max_ - min_) / 2.0) + min_;
  }
}

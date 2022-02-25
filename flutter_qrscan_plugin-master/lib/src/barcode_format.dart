class BarcodeFormat {
  final String format;

  const BarcodeFormat._(this.format);

  /// Aztec 2D barcode format.
  static const AZTEC = BarcodeFormat._('AZTEC');

  /// CODABAR 1D format.
  static const CODABAR = BarcodeFormat._('CODABAR');

  /// Code 39 1D format.
  static const CODE_39 = BarcodeFormat._('CODE_39');

  /// Code 93 1D format.
  static const CODE_93 = BarcodeFormat._('CODE_93');

  /// Code 128 1D format.
  static const CODE_128 = BarcodeFormat._('CODE_128');

  /// Data Matrix 2D barcode format.
  static const DATA_MATRIX = BarcodeFormat._('DATA_MATRIX');

  /// EAN-8 1D format.
  static const EAN_8 = BarcodeFormat._('EAN_8');

  /// EAN-13 1D format.
  static const EAN_13 = BarcodeFormat._('EAN_13');

  /// ITF (Interleaved Two of Five) 1D format.
  static const ITF = BarcodeFormat._('ITF');

  /// MaxiCode 2D barcode format.
  static const MAXICODE = BarcodeFormat._('MAXICODE');

  /// PDF417 format.
  static const PDF_417 = BarcodeFormat._('PDF_417');

  /// QR Code 2D barcode format.
  static const QR_CODE = BarcodeFormat._('QR_CODE');

  /// RSS 14
  static const RSS_14 = BarcodeFormat._('RSS_14');

  /// RSS EXPANDED
  static const RSS_EXPANDED = BarcodeFormat._('RSS_EXPANDED');

  /// UPC-A 1D format.
  static const UPC_A = BarcodeFormat._('UPC_A');

  /// UPC-E 1D format.
  static const UPC_E = BarcodeFormat._('UPC_E');

  /// UPC/EAN extension format. Not a stand-alone format.
  static const UPC_EAN_EXTENSION = BarcodeFormat._('UPC_EAN_EXTENSION');
}

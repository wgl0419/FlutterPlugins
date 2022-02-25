import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../flutter_qrscan_plugin.dart';
import 'internal/kt.dart';
import 'qr_scan_platform.dart';
import 'qr_scan_result.dart';

part 'qr_scan_view.widgets.dart';

class QrScanDisposable {
  final void Function() _invokeRescan;
  var _invoked = false;

  QrScanDisposable._(this._invokeRescan);

  void rescan() {
    if (!_invoked) {
      _invokeRescan();
    } else {
      throw Exception('invoked rescan');
    }
    _invoked = true;
  }
}

typedef QrScanFillerCallback = List<QrScanResult> Function(List<QrScanResult> results);
typedef QrScanResultCallback = void Function(QrScanResult? result, QrScanSource source, QrScanDisposable disposable);

class QrScanView extends StatefulWidget {
  final QrScanFillerCallback? onFiller;
  final QrScanResultCallback? onResult;
  final Widget? scanBar;
  final String? scanPrompt;
  final Color primaryColor;
  final bool enableTorchSwitch;
  final bool enableFromGallery;
  final bool enableLinearZoom;
  final Alignment? torchSwitchAlignment;
  final Alignment? galleryButtonAlignment;

  const QrScanView({
    Key? key,
    this.onFiller,
    this.onResult,
    this.scanBar,
    this.scanPrompt = '扫二维码 / 条码',
    this.primaryColor = Colors.green,
    this.enableTorchSwitch = true,
    this.enableFromGallery = true,
    this.enableLinearZoom = true,
    this.torchSwitchAlignment,
    this.galleryButtonAlignment,
  }) : super(key: key);

  @override
  _QrScanViewState createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> with WidgetsBindingObserver {
  final _globalKey = GlobalKey();
  final _picker = ImagePicker();
  final _controller = Completer<QrScanPlatformController>();

  double? _luminosity;
  List<QrScanResult>? _results;
  QrScanResult? _hitResult;
  Uint8List? _previewJpeg;
  Size? _previewSize;

  bool _isTorchOn = false;
  bool _isScaning = true;
  double _lastLinearZoom = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _controller.future.then((ctl) => ctl.stopCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (_isScaning) {
      final controller = await _controller.future;
      if (state == AppLifecycleState.paused) {
        controller.stopCamera();
      } else if (state == AppLifecycleState.resumed) {
        controller.startCamera();
      }
    }
  }

  void _handleLinearZoom(ScaleUpdateDetails details) async {
    if (details.scale > 1.0 && details.scale <= 6.0) {
      // 放大
      final rate = (details.scale - 1.0) / 5.0;
      final ctl = await _controller.future;
      _lastLinearZoom = _lastLinearZoom + (1.0 - _lastLinearZoom) * rate;
      if (_lastLinearZoom > 1.0) _lastLinearZoom = 1.0;
      await ctl.setLinearZoom(_lastLinearZoom);
    } else if (details.scale >= 0 && details.scale < 1.0) {
      // 缩小 0.0 - 1.0
      final rate = 1.0 - details.scale;
      final ctl = await _controller.future;
      _lastLinearZoom = _lastLinearZoom - _lastLinearZoom * rate;
      if (_lastLinearZoom < 0.0) _lastLinearZoom = 0.0;
      await ctl.setLinearZoom(_lastLinearZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _globalKey,
      children: [
        QrScanPlatformView(onCreated: _didInit),
        _isScaning ? widget.scanBar ?? _AnimatedScanBar(color: widget.primaryColor) : const SizedBox.shrink(),
        widget.enableLinearZoom ? GestureDetector(onScaleUpdate: _handleLinearZoom) : const SizedBox.shrink(),
        _buildTorchSwitch(),
        widget.enableFromGallery ? _buildFromGalleryButton() : const SizedBox.shrink(),
        _buildMarkIndicatorView(),
      ],
    );
  }

  Widget _buildFromGalleryButton() {
    return Align(
      alignment: widget.galleryButtonAlignment ?? const Alignment(0.8, 0.7),
      child: _GalleryButton(
        onTap: () async {
          final controller = await _controller.future;
          controller.stopCamera();
          setState(() {
            _isScaning = false;
          });
          final image = await _picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            final result = await FlutterQrScanPlugin.analyzeImage(image.path);
            _invokeOnResult(result, QrScanSource.gallery);
          } else {
            controller.startCamera();
          }
        },
      ),
    );
  }

  Widget _buildTorchSwitch() {
    return Align(
      alignment: widget.torchSwitchAlignment ?? const Alignment(0, 0.7),
      child: widget.enableTorchSwitch &&
              (_isTorchOn || _luminosity != null && (Platform.isAndroid ? (_luminosity! <= 0.25) : (_luminosity! <= 0)))
          ? GestureDetector(
              onTap: () async {
                final rst = await (await _controller.future).enableTorch(!_isTorchOn);
                if (rst == true) {
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                }
              },
              child: _TorchSwitch(state: _isTorchOn),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Text(
                widget.scanPrompt ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
    );
  }

  Widget _buildMarkIndicatorView() {
    if (_previewJpeg == null || _previewSize == null || _results == null) {
      return const SizedBox.shrink();
    }
    final widgetBounds = _globalKey.currentContext?.findRenderObject()?.paintBounds;
    if (widgetBounds == null) {
      return const SizedBox.shrink();
    }
    final scaleX = widgetBounds.width / _previewSize!.width;
    final scaleY = widgetBounds.height / _previewSize!.height;
    const indicatorSize = 42.0;
    return Stack(
      children: [
        Image.memory(
          _previewJpeg!,
          fit: BoxFit.cover,
          width: widgetBounds.width,
          height: widgetBounds.height,
        ),
        Container(color: const Color(0xFF000000).withOpacity(0.6)),
        ...(_hitResult == null ? _results! : [_hitResult!]).let((results) {
          return results.map((result) {
            return Positioned(
              left: ((result.centerX ?? 0.0) * scaleX) - (indicatorSize / 2.2),
              top: ((result.centerY ?? 0.0) * scaleY) - (indicatorSize / 2.2),
              child: _AnimatedIndicator(
                color: widget.primaryColor,
                onTap: () => _invokeOnResult(result, QrScanSource.camera),
                dimension: indicatorSize,
                arrow: results.length != 1,
              ),
            );
          }).toList();
        })
      ],
    );
  }

  void _didInit(QrScanPlatformController controller) {
    _controller.complete(controller);
    controller.getTorchState().then((value) {
      if (_isTorchOn != value) {
        setState(() {
          _isTorchOn = value;
        });
      }
    });
    controller.setOnFirstFrameListener(() {
      setState(() {
        _results = null;
        _hitResult = null;
        _previewJpeg = null;
        _previewSize = null;
        _isTorchOn = false;
        _isScaning = true;
      });
    });
    controller.setOnLuminosityListener((luminosity) {
      setState(() {
        _luminosity = luminosity;
      });
    });
    controller.setOnResultListener((results, previewJpeg, previewSize) async {
      final finalResults = widget.onFiller == null ? results : widget.onFiller!.call(results);
      if (finalResults.isEmpty) {
        controller.setContinueAnalyze();
        return;
      }
      if (finalResults.length == 1) {
        _invokeOnResult(finalResults.first, QrScanSource.camera);
      } else {
        controller.stopCamera();
      }
      setState(() {
        _isScaning = false;
        _hitResult = null;
        _results = finalResults;
        _previewJpeg = previewJpeg;
        _previewSize = previewSize;
      });
    });
  }

  Future<void> _invokeOnResult(
    QrScanResult? result,
    QrScanSource source,
  ) async {
    final controller = await _controller.future;
    controller.stopCamera();
    setState(() {
      _isScaning = false;
      _hitResult = result;
    });
    widget.onResult?.call(result, source, QrScanDisposable._(() {
      controller.startCamera();
    }));
  }
}

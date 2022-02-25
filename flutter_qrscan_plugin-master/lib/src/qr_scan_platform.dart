import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'qr_scan_result.dart';

typedef QrScanPlatformCreatedCallback = void Function(
    QrScanPlatformController controller);
typedef QrScanPlatformFirstFrameListener = void Function();
typedef QrScanPlatformLuminosityListener = void Function(double luminosity);
typedef QrScanPlatformResultListener = void Function(
    List<QrScanResult> results, Uint8List previewJpeg, Size previewSize);

class QrScanPlatformController {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  QrScanPlatformFirstFrameListener? _onFirstFrame;
  QrScanPlatformLuminosityListener? _onLuminosity;
  QrScanPlatformResultListener? _onResult;

  QrScanPlatformController._(this._methodChannel, this._eventChannel) {
    _eventChannel.receiveBroadcastStream().listen((event) {
      final action = event['action'];
      if ('onFirstFrame' == action) {
        _onFirstFrame?.call();
      } else if ('onLuminosity' == action) {
        _onLuminosity?.call(event['luminosity']);
      } else if ('onResult' == action) {
        final results = <QrScanResult>[];
        event['results'].forEach((it) {
          final barcodeFormat = it['barcodeFormat'];
          final text = it['text'];
          final points = <Point<double>>[];
          it['points'].forEach((it) {
            points.add(Point<double>(it[0], it[1]));
          });
          results.add(QrScanResult(
            barcodeFormat: barcodeFormat,
            text: text,
            points: points,
          ));
        });
        final previewJpeg = event['previewJpeg'];
        final previewSize = event['previewSize'];
        _onResult?.call(
          results,
          previewJpeg,
          Size(previewSize[0].toDouble(), previewSize[1].toDouble()),
        );
      }
    });
  }

  void setOnFirstFrameListener(QrScanPlatformFirstFrameListener? listener) {
    _onFirstFrame = listener;
  }

  void setOnLuminosityListener(QrScanPlatformLuminosityListener? listener) {
    _onLuminosity = listener;
  }

  void setOnResultListener(QrScanPlatformResultListener? listener) {
    _onResult = listener;
  }

  Future<bool> startCamera() async {
    final result = await _methodChannel.invokeMethod("startCamera");
    return result;
  }

  Future<bool> stopCamera() async {
    final result = await _methodChannel.invokeMethod("stopCamera");
    return result;
  }

  Future<bool> enableTorch(bool troch) async {
    final result = await _methodChannel.invokeMethod("enableTorch", troch);
    return result;
  }

  Future<bool> setLinearZoom(double linearZoom) async {
    final result =
        await _methodChannel.invokeMethod("setLinearZoom", linearZoom);
    return result;
  }

  Future<bool> getTorchState() async {
    final result = await _methodChannel.invokeMethod("getTorchState");
    return result;
  }

  Future<bool> setContinueAnalyze() async {
    final result = await _methodChannel.invokeMethod("setContinueAnalyze");
    return result;
  }
}

class QrScanPlatformView extends StatefulWidget {
  static const _viewTypeId = 'dev.flutter.qrscan_plugin/QrScanPlatformView';

  final QrScanPlatformCreatedCallback onCreated;

  const QrScanPlatformView({
    Key? key,
    required this.onCreated,
  }) : super(key: key);

  @override
  State<QrScanPlatformView> createState() => _QrScanPlatformViewState();
}

class _QrScanPlatformViewState extends State<QrScanPlatformView> {
  // final _completer = Completer<int>();
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
        // const _methodChannel = MethodChannel(QrScanPlatformView._viewTypeId);
        // final id = await _methodChannel.invokeMethod('initialize');
        // _completer.complete(id);
        // final _eventChannel =
        //     EventChannel('${QrScanPlatformView._viewTypeId}/event#$id');
        // widget.onCreated(
        //     QrScanPlatformController._(_methodChannel, _eventChannel));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return _buildAndroidPlatformView();
    } else if (Platform.isIOS) {
      return _buildIOSPlatformView();
      // return FutureBuilder(
      //   builder: (context, AsyncSnapshot<int> snapshot) {
      //     if (snapshot.hasData) {
      //       return Texture(
      //         textureId: snapshot.data!,
      //         filterQuality: FilterQuality.none,
      //       );
      //     }
      //     return const SizedBox();
      //   },
      //   future: _completer.future,
      // );
    } else {
      return const Center(
        child: Text('not support'),
      );
    }
  }

  Widget _buildIOSPlatformView() {
    return UiKitView(
      viewType: QrScanPlatformView._viewTypeId,
      onPlatformViewCreated: (viewId) {
        final controller = QrScanPlatformController._(
          MethodChannel('${QrScanPlatformView._viewTypeId}/method#$viewId'),
          EventChannel('${QrScanPlatformView._viewTypeId}/event#$viewId'),
        );
        widget.onCreated(controller);
      },
    );
  }

  Widget _buildAndroidPlatformView() {
    return AndroidView(
      viewType: QrScanPlatformView._viewTypeId,
      onPlatformViewCreated: (viewId) {
        final controller = QrScanPlatformController._(
          MethodChannel('${QrScanPlatformView._viewTypeId}/method#$viewId'),
          EventChannel('${QrScanPlatformView._viewTypeId}/event#$viewId'),
        );
        widget.onCreated(controller);
      },
    );
  }
}

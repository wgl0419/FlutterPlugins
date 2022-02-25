import Flutter
import UIKit

public class SwiftFlutterQrscanPlugin: NSObject, FlutterPlugin {
  var qrScanView: QRScanView!
    
  public static func register(with registrar: FlutterPluginRegistrar) {
//    let instance = SwiftFlutterQrscanPlugin()
//      instance.qrScanView = QRScanView.init(textureRegistry: registrar.textures(), binaryMessager: registrar.messenger())
      let viewFactory = FlutterQRScanViewFactory(messenger: registrar.messenger())
      registrar.register(viewFactory, withId: "dev.flutter.qrscan_plugin/QrScanPlatformView")
  }
}

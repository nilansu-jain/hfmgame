import AVKit
import Flutter
import UIKit

final class AirPlayRoutePickerFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return AirPlayRoutePickerPlatformView(frame: frame)
  }
}

final class AirPlayRoutePickerPlatformView: NSObject, FlutterPlatformView {
  private let routePickerView: AVRoutePickerView

  init(frame: CGRect) {
    routePickerView = AVRoutePickerView(frame: frame)
    super.init()

    routePickerView.backgroundColor = .clear
    routePickerView.tintColor = UIColor(red: 0.05, green: 0.11, blue: 0.20, alpha: 1)
    routePickerView.activeTintColor = UIColor(red: 0.05, green: 0.11, blue: 0.20, alpha: 1)
    routePickerView.prioritizesVideoDevices = false
  }

  func view() -> UIView {
    return routePickerView
  }
}

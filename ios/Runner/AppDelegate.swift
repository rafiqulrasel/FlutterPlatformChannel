import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
       let controller = window?.rootViewController as! FlutterViewController
            let channel = FlutterMethodChannel(name: "com.example.app/version", binaryMessenger: controller.binaryMessenger)

            channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
                if call.method == "getVersionInfo" {
                    if let versionInfo = self.getVersionInfo() {
                        result(versionInfo)
                    } else {
                        result(FlutterError(code: "UNAVAILABLE", message: "Version info not available", details: nil))
                    }
                }else  if call.method == "showToast" {
                if let args = call.arguments as? [String: Any],
                    let message = args["message"] as? String {
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    controller.present(alert, animated: true, completion: nil)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
   private func getVersionInfo() -> [String: Any]? {
          if let infoDictionary = Bundle.main.infoDictionary {
              let versionName = infoDictionary["CFBundleShortVersionString"] as? String ?? "Unknown"
              let versionCode = infoDictionary["CFBundleVersion"] as? String ?? "Unknown"
              return [
                  "versionName": versionName,
                  "versionCode": versionCode
              ]s
          }
          return nil
      }
}

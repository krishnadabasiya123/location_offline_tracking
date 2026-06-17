import Flutter
import UIKit

import FirebaseCore
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin: "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
    }


    FirebaseApp.configure()
    
    // Register plugins for the main isolate
    GeneratedPluginRegistrant.register(with: self)
    
    // Check if the app was launched due to a location event
    if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
        // The system launched the app in the background for a location update
    }
    
    // Set up Method Channel for Native Logging in iOS Release Mode
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let logChannel = FlutterMethodChannel(name: "com.omkar.sale/native_logger",
                                              binaryMessenger: controller.binaryMessenger)
    logChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "log" {
        if let args = call.arguments as? [String: Any],
           let message = args["message"] as? String {
             NSLog("[Dart-Release] %@", message)
             result(nil)
        } else {
             result(FlutterError(code: "INVALID_ARGUMENTS", message: "Message is empty", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

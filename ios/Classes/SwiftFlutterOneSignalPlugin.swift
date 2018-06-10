import Flutter
import UIKit
import OneSignal

public class SwiftFlutterOneSignalPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_one_signal/methods", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "flutter_one_signal/events", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterOneSignalPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "startInit"){
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            let map = call.arguments as? Dictionary<String, String>
            let appId = map?["appId"]
            print("appId here")
            print(appId)
            
            OneSignal.initWithLaunchOptions(nil,
                                            appId: appId,
                                            handleNotificationAction: nil,
                                            settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

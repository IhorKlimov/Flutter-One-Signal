import Flutter
import UIKit
import OneSignal

public class SwiftFlutterOneSignalPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    
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
            
            print(map)
            let inFocusDisplaying = parseInFocusDisplaying(map: map!)
            
            let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
                self.sink!("opened:" + result!.notification.stringify())
            }
            
            OneSignal.initWithLaunchOptions(nil,
                                            appId: appId,
                                            handleNotificationAction: notificationOpenedBlock,
                                            settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = inFocusDisplaying
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
        }else if (call.method == "setTag"){
            let map = call.arguments as? Dictionary<String, String>
            let key = map?["key"]
            let value = map?["value"]
            
            OneSignal.sendTag(key, value: value)
        }
    }
    
    private func parseInFocusDisplaying(map: Dictionary<String, String> ) -> OSNotificationDisplayType{
        let inFocusDisplaying = map["inFocusDisplaying"]
        if (inFocusDisplaying == "OSInFocusDisplayOption.InAppAlert.InAppAlert"){
            return OSNotificationDisplayType.inAppAlert
        }else if (inFocusDisplaying == "OSInFocusDisplayOption.InAppAlert.Notification"){
            return OSNotificationDisplayType.notification
        } else {
            return OSNotificationDisplayType.none
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}

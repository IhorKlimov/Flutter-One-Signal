import Flutter
import UIKit
import OneSignal

public class SwiftFlutterOneSignalPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, OSSubscriptionObserver {
    private var sink: FlutterEventSink?
    private var result: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_one_signal/methods", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "flutter_one_signal/events", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterOneSignalPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "startInit") {
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            let map = call.arguments as? Dictionary<String, String>
            let appId = map?["appId"]

            let inFocusDisplaying = parseInFocusDisplaying(map: map!)
            
            let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
                self.sink!("opened:" + result!.notification.stringify())
            }

            let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
                self.sink!("received:" + notification!.stringify())
            }
            
            OneSignal.initWithLaunchOptions(nil,
                                            appId: appId,
                                            handleNotificationReceived: notificationReceivedBlock,
                                            handleNotificationAction: notificationOpenedBlock,
                                            settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = inFocusDisplaying
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
                result(accepted)
            })
        } else if (call.method == "sendTag") {
            let map = call.arguments as? Dictionary<String, String>
            let key = map?["key"]
            let value = map?["value"]
            
            OneSignal.sendTag(key, value: value)
        } else if (call.method == "setEmail") {
            let map = call.arguments as? Dictionary<String, String>
            let email = map?["email"]

            OneSignal.setEmail(email!)
        } else if (call.method == "logoutEmail") {
          OneSignal.logoutEmail();
        } else if (call.method == "setSubscription") {
            let map = call.arguments as? Dictionary<String, Any>
            let enable: Bool = (map?["enable"] as? Bool)!
            OneSignal.setSubscription(enable)
        } else if (call.method == "getUserId") {
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            if (userID != nil){
                result(userID)
            } else {
                self.result = result
                OneSignal.add(self as OSSubscriptionObserver)
            }
        }
    }
    
    public func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if (stateChanges.to.userId != nil){
            result?(stateChanges.to.userId)
            OneSignal.remove(self as OSSubscriptionObserver)
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

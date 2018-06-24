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
        } else if (call.method == "getUserId") {
            // https://documentation.onesignal.com/docs/ios-native-sdk#section--getpermissionsubscriptionstate-
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            
            let hasPrompted = status.permissionStatus.hasPrompted
            print("hasPrompted = \(hasPrompted)")
            let userStatus = status.permissionStatus.status
            print("userStatus = \(userStatus)")
            let isSubscribed = status.subscriptionStatus.subscribed
            print("isSubscribed = \(isSubscribed)")
            let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
            print("userSubscriptionSetting = \(userSubscriptionSetting)")
            let userID = status.subscriptionStatus.userId
            print("userID = \(userID)")

            if (isSubscribed) {
                result(userID)
            } else {
                result(FlutterError.init(code: "DISABLED",
                             message: "OneSignal subscription is disabled",
                             details: nil));
            }
            
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

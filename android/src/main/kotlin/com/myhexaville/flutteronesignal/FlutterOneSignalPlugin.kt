package com.myhexaville.flutteronesignal

import com.onesignal.*
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.EventChannel

class FlutterOneSignalPlugin(private val registrar: Registrar)
    : MethodCallHandler, EventChannel.StreamHandler, OSSubscriptionObserver {
    private var sink: EventChannel.EventSink? = null
    private var result: Result? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val methodsChannel = MethodChannel(registrar.messenger(), "flutter_one_signal/methods")
            val eventChannel = EventChannel(registrar.messenger(), "flutter_one_signal/events")

            val instance = FlutterOneSignalPlugin(registrar)
            methodsChannel.setMethodCallHandler(instance)
            eventChannel.setStreamHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startInit" -> startInit(call, result)
            "sendTag" -> sendTag(call)
            "setEmail" -> setEmail(call)
            "logoutEmail" -> logoutEmail(call)
            "setSubscription" -> setSubscription(call)
            "getUserId" -> getUserId(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onListen(p0: Any?, sink: EventChannel.EventSink?) {
        this.sink = sink
    }

    override fun onCancel(p0: Any?) {
    }

    private fun setSubscription(call: MethodCall) {
        val enable = call.argument<Boolean>("enable")

        OneSignal.setSubscription(enable)
    }

    private fun startInit(call: MethodCall, result: Result) {
        val inFocusDisplaying = parseInFocusDisplaying(call)
        val unsubscribeWhenNotificationsAreDisabled = parseUnsubscribeWhenNotificationsAreDisabled(call)

        OneSignal.startInit(registrar.context())
                .inFocusDisplaying(inFocusDisplaying)
                .setNotificationOpenedHandler { result ->
                    sink?.success("opened:${result?.notification?.toJSONObject().toString()}")
                }
                .setNotificationReceivedHandler({ notification ->
                    sink?.success("received:${notification.toJSONObject().toString()}")
                })
                .unsubscribeWhenNotificationsAreDisabled(unsubscribeWhenNotificationsAreDisabled)
                .init()
        result.success(true)
    }

    private fun sendTag(call: MethodCall) {
        val key = call.argument<String>("key")
        val value = call.argument<String>("value")

        OneSignal.sendTag(key, value)
    }

    private fun setEmail(call: MethodCall) {
        val email = call.argument<String>("email")
        OneSignal.setEmail(email)
    }

    private fun logoutEmail(call: MethodCall) {
        OneSignal.logoutEmail()
    }

    private fun getUserId(call: MethodCall, result: Result) {
        val status = OneSignal.getPermissionSubscriptionState()
        val userId = status.subscriptionStatus.userId
        if (userId == null) {
            this.result = result
            OneSignal.addSubscriptionObserver(this)
        } else {
            result.success(status.subscriptionStatus.userId)
        }
    }

    private fun parseUnsubscribeWhenNotificationsAreDisabled(call: MethodCall): Boolean {
        return call.argument<String>("unsubscribeWhenNotificationsAreDisabled").toBoolean()
    }

    private fun parseInFocusDisplaying(call: MethodCall): OneSignal.OSInFocusDisplayOption {
        val inFocusDisplaying = call.argument<String>("inFocusDisplaying")
        return when (inFocusDisplaying) {
            "OSInFocusDisplayOption.InAppAlert" -> OneSignal.OSInFocusDisplayOption.InAppAlert
            "OSInFocusDisplayOption.Notification" -> OneSignal.OSInFocusDisplayOption.Notification
            else -> OneSignal.OSInFocusDisplayOption.None
        }
    }

    override fun onOSSubscriptionChanged(stateChanges: OSSubscriptionStateChanges?) {
        if (stateChanges?.to?.userId != null) {
            result?.success(stateChanges.to?.userId)
            OneSignal.removeSubscriptionObserver(this)
        }
    }
}

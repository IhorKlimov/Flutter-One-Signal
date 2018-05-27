package com.myhexaville.flutteronesignal

import com.onesignal.OneSignal
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.EventChannel

class FlutterOneSignalPlugin(private val registrar: Registrar)
    : MethodCallHandler, EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

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
        if (call.method == "startInit") {
            startInit(call)
        } else {
            result.notImplemented()
        }
    }

    override fun onListen(p0: Any?, sink: EventChannel.EventSink?) {
        this.sink = sink
    }

    override fun onCancel(p0: Any?) {
    }

    private fun startInit(call: MethodCall) {
        val inFocusDisplaying = parseInFocusDisplaying(call)
        val unsubscribeWhenNotificationsAreDisabled = parseUnsubscribeWhenNotificationsAreDisabled(call)

        println(inFocusDisplaying)
        println(unsubscribeWhenNotificationsAreDisabled)

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
    }

    private fun parseUnsubscribeWhenNotificationsAreDisabled(call: MethodCall): Boolean {
        val unsubscribeWhenNotificationsAreDisabled = call.argument<String>("unsubscribeWhenNotificationsAreDisabled")
        return !(unsubscribeWhenNotificationsAreDisabled == null || unsubscribeWhenNotificationsAreDisabled == "false")
    }

    private fun parseInFocusDisplaying(call: MethodCall): OneSignal.OSInFocusDisplayOption {
        val inFocusDisplaying = call.argument<String>("inFocusDisplaying")
        return if (inFocusDisplaying == null || inFocusDisplaying == "InAppAlert") {
            OneSignal.OSInFocusDisplayOption.InAppAlert
        } else if (inFocusDisplaying == "Notification") {
            OneSignal.OSInFocusDisplayOption.Notification
        } else {
            OneSignal.OSInFocusDisplayOption.None
        }
    }
}

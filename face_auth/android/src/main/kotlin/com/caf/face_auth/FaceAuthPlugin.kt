package com.caf.face_auth

import android.content.Context
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import input.CafStage
import input.iproov.Filter
import input.FaceAuthenticator
import input.Time
import output.FaceAuthenticatorResult
import input.VerifyAuthenticationListener
import output.FaceAuthenticatorErrorResult

class FaceAuthPlugin: FlutterPlugin {

    companion object {
        private const val START_METHOD_CALL = "start"
        private const val METHOD_CHANNEL_NAME = "face_authenticator"
        private const val EVENT_CHANNEL_NAME = "face_auth_listener"
        private const val SUCCESS_EVENT = "success"
        private const val FAILURE_EVENT = "failure"
        private const val CANCELED_EVENT = "canceled"
        private const val CONNECTED_EVENT = "connected"
        private const val CONNECTING_EVENT = "connecting"
    }

    private lateinit var eventChannel: EventChannel
    private lateinit var methodChannel: MethodChannel

    private var eventSink: EventChannel.EventSink? = null
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    private val methodCallHandler = MethodChannel.MethodCallHandler { call, result ->
        if (call.method == START_METHOD_CALL) {
            start(call)
        } else {
            result.notImplemented()
        }
    }

    private fun start(call: MethodCall) {
        val context: Context? = flutterPluginBinding?.applicationContext

        val argumentsMap = call.arguments as HashMap<*, *>

        // Mobile token
        val mobileToken = argumentsMap["mobileToken"] as String

        // PersonID
        val personId = argumentsMap["personId"] as String

        val mFaceAuthenticatorBuilder = FaceAuthenticator.Builder(mobileToken)

        // Stage
        val stage = argumentsMap["stage"] as String?
        stage?.let { mFaceAuthenticatorBuilder.setStage(CafStage.valueOf(it)) }

        // Filter
        val filter = argumentsMap["filter"] as String?
        filter?.let { mFaceAuthenticatorBuilder.setFilter(Filter.valueOf(it)) }

        // Enable Screenshot
        val enableScreenshot = argumentsMap["enableScreenshot"] as Boolean?
        enableScreenshot?.let { mFaceAuthenticatorBuilder.setEnableScreenshots(it) }

        // Enable SDK default loading screen
        val enableLoadingScreen = argumentsMap["enableLoadingScreen"] as Boolean?
        enableLoadingScreen?.let { mFaceAuthenticatorBuilder.setLoadingScreen(it) }

        // Customize the image URL Expiration Time
        val imageUrlExpirationTime = argumentsMap["imageUrlExpirationTime"] as String?
        imageUrlExpirationTime?.let { mFaceAuthenticatorBuilder.setImageUrlExpirationTime(Time.valueOf(it)) }

        //FaceAuth build
        mFaceAuthenticatorBuilder.build().authenticate(context, personId, object : VerifyAuthenticationListener {
            override fun onSuccess(faceAuthResult: FaceAuthenticatorResult) {
                android.os.Handler(Looper.getMainLooper()).post {
                    eventSink?.success(getSuccessResponseMap(faceAuthResult))
                    eventSink?.endOfStream()
                }
            }

            override fun onError(sdkFailure: FaceAuthenticatorErrorResult) {
                android.os.Handler(Looper.getMainLooper()).post {
                    eventSink?.success(getErrorResponseMap(sdkFailure))
                    eventSink?.endOfStream()
                }
            }


            override fun onCancel() {
                android.os.Handler(Looper.getMainLooper()).post {
                    eventSink?.success(getClosedResponseMap())
                    eventSink?.endOfStream()
                }
            }

            override fun onLoading() {
                android.os.Handler(Looper.getMainLooper()).post {
                    eventSink?.success(getConnectingResponseMap())
                }
            }

            override fun onLoaded() {
                android.os.Handler(Looper.getMainLooper()).post {
                    eventSink?.success(getConnectedResponseMap())
                }
            }

        })
    }

    private fun getSuccessResponseMap(result: FaceAuthenticatorResult): HashMap<String, Any> {
        val responseMap = HashMap<String, Any>()
        responseMap["event"] = SUCCESS_EVENT
        responseMap["signedResponse"] = result.signedResponse
        return responseMap
    }

    private fun getErrorResponseMap(sdkFailure: FaceAuthenticatorErrorResult): HashMap<String, Any> {
        val responseMap = HashMap<String, Any>()
        responseMap["event"] = FAILURE_EVENT
        responseMap["errorType"] = sdkFailure.errorType.value
        responseMap["errorDescription"] = sdkFailure.description

        return responseMap
    }

    private fun getClosedResponseMap(): HashMap<String, Any> {
        val responseMap = HashMap<String, Any>()
        responseMap["event"] = CANCELED_EVENT
        return responseMap
    }

    private fun getConnectingResponseMap(): HashMap<String, Any> {
        val responseMap = HashMap<String, Any>()
        responseMap["event"] = CONNECTING_EVENT
        return responseMap
    }

    private fun getConnectedResponseMap(): HashMap<String, Any> {
        val responseMap = HashMap<String, Any>()
        responseMap["event"] = CONNECTED_EVENT
        return responseMap
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = binding

        methodChannel = MethodChannel(flutterPluginBinding!!.binaryMessenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(methodCallHandler)

        eventChannel = EventChannel(flutterPluginBinding!!.binaryMessenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        this.flutterPluginBinding = null
    }
}

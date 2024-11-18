import Flutter
import UIKit
import FaceAuth
import FaceLiveness

public class FaceAuthPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    var faceAuth: FaceAuthSDK?
    var sink: FlutterEventSink?
    var sdkResult : [String: Any?] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.methodChannelName, binaryMessenger: registrar.messenger())
        let instance = FaceAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        FlutterEventChannel(name: Constants.eventChannelName, binaryMessenger: registrar.messenger())
            .setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == Constants.start {
            do {
                start(call: call);
            }
            result(nil)
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
    
    private func start(call: FlutterMethodCall) {
        
        guard let arguments = call.arguments as? [String: Any?] else {
            fatalError(Constants.argumentsErrorMessage)
        }
        
        guard let mobileToken = arguments["mobileToken"] as? String else {
            fatalError(Constants.mobileTokenErrorMessage)
        }
        
        guard let personId = arguments["personId"] as? String else {
            fatalError(Constants.personIdErrorMessage)
        }
        
        let mFaceAuthBuilder = FaceAuthSDK.Builder()

        //Stage
        if let stage = arguments["stage"] as? String ?? nil {
            _ = mFaceAuthBuilder.setStage(stage: getCafStage(stage: stage))
        }

        //Camera Filter
        if let filter = arguments["filter"] as? String ?? nil {
            _ = mFaceAuthBuilder.setFilter(filter: getFilter(filter: filter))
        }
        
        // Enable SDK default loading screen
        if let enableLoadingScreen = arguments["enableLoadingScreen"] as? Bool ?? nil {
            _ = mFaceAuthBuilder.setLoading(withLoading: enableLoadingScreen)
        }

        if let expirationTime = arguments["imageUrlExpirationTime"] as? String ?? nil {
            _ = mFaceAuthBuilder.setImageUrlExpirationTime(time: getExpirationTime(time: expirationTime))
        }

        //FaceAuthenticator Build
        self.faceAuth = mFaceAuthBuilder.build()
        faceAuth?.delegate = self
        faceAuth?.sdkType = .Flutter

        guard let viewController = UIApplication.shared.currentKeyWindow?.rootViewController else {
            fatalError(Constants.viewControllerErrorMessage)
        }
        
        faceAuth?.startFaceAuthSDK(viewController: viewController, mobileToken: mobileToken, personId: personId)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            sink = events
            
            return nil
        }
        
        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            sink = nil
            
            return nil
        }
}

extension FaceAuthPlugin: FaceAuthSDKDelegate {
    
    public func didFinishSuccess(with faceAuthenticatorResult: FaceAuthenticatorResult) {
        sdkResult["event"] = Constants.eventSuccess
        sdkResult["signedResponse"] = faceAuthenticatorResult.signedResponse
        
        self.sink?(sdkResult)
        self.sink?(FlutterEndOfEventStream)
        faceAuth = nil
    }
    
    public func didFinishWithError(with faceAuthenticatorErrorResult: FaceAuth.FaceAuthenticatorErrorResult) {
        sdkResult["event"] = Constants.eventError
        sdkResult["errorType"] = faceAuthenticatorErrorResult.errorType?.rawValue
        sdkResult["errorDescription"] = faceAuthenticatorErrorResult.description
        
        self.sink?(sdkResult)
        self.sink?(FlutterEndOfEventStream)
        faceAuth = nil
    }
    
    public func didFinishFaceAuthWithCancelled() {
        sdkResult["event"] = Constants.eventCanceled
        
        self.sink?(sdkResult)
        self.sink?(FlutterEndOfEventStream)
        faceAuth = nil
    }
    
    public func openLoadingScreenStartSDK() {
        sdkResult["event"] = Constants.eventConnecting
                
        self.sink?(sdkResult)
    }
    
    public func closeLoadingScreenStartSDK() {
        sdkResult["event"] = Constants.eventConnected
                
        self.sink?(sdkResult)
    }
    
    public func openLoadingScreenValidation() {
        sdkResult["event"] = Constants.eventValidating
                
        self.sink?(sdkResult)
    }
    
    public func closeLoadingScreenValidation() {
        sdkResult["event"] = Constants.eventValidated
                
        self.sink?(sdkResult)
    }
}

//
//  FlutterDocumentProxy.swift
//  Runner
//
//  Created by lvsheng on 2024/5/24.
//

import Flutter
import UIKit

public class FlutterDocumentProxy: NSObject, FlutterPlugin {
    public static let sharedInstance = FlutterDocumentProxy()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "document_proxy", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(sharedInstance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getRootDirUri":
            handleGetRootDirUri(result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleGetRootDirUri(result:  @escaping FlutterResult) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        if let future = appDelegate.ubiquityUrlFuture {
            let _ = appDelegate.ubiquityUrlFuture?.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    result(FlutterError(code: "Fail", message: error.userInfo.description, details: error))
                }
            }, receiveValue: { value in
                result(value.appendingPathComponent("Document", isDirectory: true).absoluteString)
            })
        } else {
            result(FlutterError(code: "NotReady", message: "AppDelegate not ready for ubiquityUrlFuture", details: nil))
        }
    }
}

import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /*
    override func application(_ application: UIApplication,
                              open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        let sendingAppID = options[.sourceApplication]
        print("source application = \(sendingAppID ?? "Unknown")")
        
        if url.scheme != "lsreadingnoteapp" {
            print("Invalid scheme")
            return false
        }
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let path = components.path,
              let params = components.queryItems else {
            print("Invalid URL or path missing")
            return false
        }
        
        if path != "/import-file" {
            print("Invalid Path")
            return false
        }

        if let fileUrl = params.first(where: { $0.name == "url" })?.value?.removingPercentEncoding {
            print("url = \(fileUrl)")
            return true
        } else {
            print("file url missing")
            return false
        }
    }
    */
}

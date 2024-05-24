import Flutter
import UIKit
import Combine

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var ubiquityUrlFuture: Future<URL, NSError>?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        fillUbiquityUrlFuture()

        GeneratedPluginRegistrant.register(with: self)
        FlutterDocumentProxy.register(with: ((window?.rootViewController as! FlutterViewController).engine?.registrar(forPlugin: "DocumentProxy"))!)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // todo:
        // NSFileCoordinator.removeFilePresenter(<#T##filePresenter: any NSFilePresenter##any NSFilePresenter#>)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // todo
        // NSFileCoordinator.addFilePresenter(<#T##filePresenter: any NSFilePresenter##any NSFilePresenter#>)
    }
    
    private func fillUbiquityUrlFuture() {
        if FileManager.default.ubiquityIdentityToken == nil {
            ubiquityUrlFuture = Future { promise in
                promise(.failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 1, userInfo: [NSLocalizedDescriptionKey: "No iCloud ID"])))
            }
        } else {
            // todo: save icloud id, listen to change, when change/logOut, clear cache and refresh
            //   @see: https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW6
            print("icloud id: \(String(describing: FileManager.default.ubiquityIdentityToken))")

            ubiquityUrlFuture = Future() { promise in
                DispatchQueue.global(qos: .default).async { [weak self] in
                    guard let self = self else { return }
                    if let icloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                        promise(Result.success(icloudContainer))
                    } else {
                        promise(.failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Get UbiquityContainerUrl Fail"])))
                    }
                }
            }
        }
    }
}

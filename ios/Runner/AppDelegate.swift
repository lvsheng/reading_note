import Flutter
import UIKit
import Combine

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var ubiquityUrlSubject = CurrentValueSubject<URL?, NSError>(nil)

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        fillUbiquityUrlSubject()

        GeneratedPluginRegistrant.register(with: self)
        FlutterDocumentProxy.register(with: ((window?.rootViewController as! FlutterViewController).engine?.registrar(forPlugin: "DocumentProxy"))!)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        if let filePresenter = FlutterDocumentProxy.sharedInstance.filePresenter {
            NSFileCoordinator.removeFilePresenter(filePresenter)
        }
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        if let filePresenter = FlutterDocumentProxy.sharedInstance.filePresenter {
             NSFileCoordinator.addFilePresenter(filePresenter)
        }
    }
    
    private func fillUbiquityUrlSubject() {
        if FileManager.default.ubiquityIdentityToken == nil {
            ubiquityUrlSubject.send(completion: .failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 1, userInfo: [NSLocalizedDescriptionKey: "No iCloud ID"])))
        } else {
            // todo: save icloud id, listen to change, when change/logOut, clear cache and refresh
            //   @see: https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW6
            print("got icloud id")

            DispatchQueue.global(qos: .default).async { [weak self] in
                guard let self = self else { return }
                if let icloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                    print("got icloudContainer")
                    self.ubiquityUrlSubject.send(icloudContainer)
                    self.ubiquityUrlSubject.send(completion: .finished)
                } else {
                    self.ubiquityUrlSubject.send(completion: .failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Get UbiquityContainerUrl Fail"])))
                }
            }
        }
    }
}

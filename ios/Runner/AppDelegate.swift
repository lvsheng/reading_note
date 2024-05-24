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
        // todo:
        // NSFileCoordinator.removeFilePresenter(<#T##filePresenter: any NSFilePresenter##any NSFilePresenter#>)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // todo
        // NSFileCoordinator.addFilePresenter(<#T##filePresenter: any NSFilePresenter##any NSFilePresenter#>)
    }
    
    let icloudFileManager = iCloudFileManager()

    private func fillUbiquityUrlSubject() {
        if FileManager.default.ubiquityIdentityToken == nil {
            ubiquityUrlSubject.send(completion: .failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 1, userInfo: [NSLocalizedDescriptionKey: "No iCloud ID"])))
        } else {
            // todo: save icloud id, listen to change, when change/logOut, clear cache and refresh
            //   @see: https://developer.apple.com/library/archive/documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html#//apple_ref/doc/uid/TP40012094-CH6-SW6
            print("icloud id: \(String(describing: FileManager.default.ubiquityIdentityToken))")

            DispatchQueue.global(qos: .default).async { [weak self] in
                guard let self = self else { return }
                if let icloudContainer = FileManager.default.url(forUbiquityContainerIdentifier: nil) {

                    icloudFileManager.listFilesInICloudContainer()

                    print("got icloudContainer: \(icloudContainer)")
                    self.ubiquityUrlSubject.send(icloudContainer)
                    self.ubiquityUrlSubject.send(completion: .finished)
                } else {
                    self.ubiquityUrlSubject.send(completion: .failure(NSError(domain: Bundle.main.bundleIdentifier ?? "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Get UbiquityContainerUrl Fail"])))
                }
            }
        }
    }
}

class iCloudFileManager {
    let fileManager = FileManager.default
    // Create a query to search for documents in the iCloud container
    let query = NSMetadataQuery()

    func listFilesInICloudContainer() {
        // Get the URL of the iCloud container
        guard let containerURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            print("iCloud container not available.")
            return
        }
        
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        
        // Set up a notification to handle query results
        NotificationCenter.default.addObserver(self, selector: #selector(queryDidFinishGathering(_:)), name: .NSMetadataQueryDidFinishGathering, object: query)
        
        // Start the query
        query.start()
    }
    
    @objc func queryDidFinishGathering(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        
        query.disableUpdates()
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
        
        for item in query.results {
            if let metadataItem = item as? NSMetadataItem,
               let url = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL {
                
                let fileName = url.lastPathComponent
                
                // Check if the file is downloaded
                let isDownloaded = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String == NSMetadataUbiquitousItemDownloadingStatusCurrent
                let isDownloading = metadataItem.value(forAttribute: NSMetadataUbiquitousItemIsDownloadingKey) as? Bool ?? false
                let isUploaded = metadataItem.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool ?? false
                let isUploading = metadataItem.value(forAttribute: NSMetadataUbiquitousItemIsUploadingKey) as? Bool ?? false
                
                print("File: \(fileName)")
                print(" - Downloaded: \(isDownloaded)")
                print(" - Downloading: \(isDownloading)")
                print(" - Uploaded: \(isUploaded)")
                print(" - Uploading: \(isUploading)")
                
                // Optionally, handle downloading or uploading files if needed
            }
        }
        
        query.stop()
    }
}

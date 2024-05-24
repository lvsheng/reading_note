import Flutter
import UIKit
import Combine

public class FlutterDocumentProxy: NSObject, FlutterPlugin {
    public static let sharedInstance = FlutterDocumentProxy()

    private var cancellables = Set<AnyCancellable>()
    private var rootDirectorySubject = CurrentValueSubject<URL?, NSError>(nil)
    private var filePresenter: DocumentDirPresenter?

    public static func register(with registrar: FlutterPluginRegistrar) {
        sharedInstance.fillRootDirectorySubject()

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

    private func handleGetRootDirUri(result: @escaping FlutterResult) {
        if let rootDirectory = rootDirectorySubject.value {
            result(rootDirectory.absoluteString)
        } else {
            rootDirectorySubject.dropFirst().sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result(FlutterError(code: "Fail", message: error.userInfo.description, details: error))
                    break
                case .finished:
                    break
                }
            }, receiveValue: { value in
                print("rootDirectorySubject.receiveValue \(String(describing: value))")
                result(value!.absoluteString)
            }).store(in: &cancellables)
        }
    }
    
    private func fillRootDirectorySubject() {
        rootDirectorySubject.dropFirst().sink(receiveCompletion: { completion in
            
        }, receiveValue: { [weak self] value in
            guard let self = self else { return }
            print("rootDirectorySubject.receiveValue2 \(String(describing: value))")
            self.filePresenter = DocumentDirPresenter(presentedItemURL: value!)
        }).store(in: &cancellables)
        
        (UIApplication.shared.delegate as! AppDelegate).ubiquityUrlSubject.dropFirst().sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                self.rootDirectorySubject.send(completion: .failure(error))
                break
            case .finished:
                break
            }
        }, receiveValue: { [weak self] value in
            print("ubiquityUrlSubject.receiveValue \(String(describing: value))")
            guard let self = self else { return }
            self.rootDirectorySubject.send(value!.appendingPathComponent("Documents", isDirectory: true))
            self.rootDirectorySubject.send(completion: .finished)
        }).store(in: &cancellables)
    }
}

private class DocumentDirPresenter: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue = OperationQueue()
    
    init(presentedItemURL: URL) {
        self.presentedItemURL = presentedItemURL
        super.init()
        NSFileCoordinator.addFilePresenter(self)

        let coordinator = NSFileCoordinator(filePresenter: self)
        var error: NSError?

        if !FileManager.default.fileExists(atPath: presentedItemURL.path) {
            print("!fileExists: \(presentedItemURL)")
            coordinator.coordinate(writingItemAt: presentedItemURL, options: .forReplacing, error: &error) { (newURL) in
                do {
                    try FileManager.default.createDirectory(at: presentedItemURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Failed to create Documents directory in iCloud container: \(error)")
                }
            }
        } else {
            print("presentedItemURL exist: \(presentedItemURL)")
        }
        
        let fileURL = presentedItemURL.appendingPathComponent("example3.txt")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("file already exist: \(fileURL)")
            let isUbiquitous = FileManager.default.isUbiquitousItem(at: fileURL)
            print("isUbiquitousItem:\(isUbiquitous) for \(fileURL)")
        } else {
            print("file still not exist: \(fileURL)")
        }

        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &error) { (newURL) in
            let content = "Hello, iCloud!".data(using: .utf8)
            do {
                try content?.write(to: newURL, options: .atomic)
                print("File successfully created at \(newURL)")
            } catch {
                print("Failed to write file: \(error)")
            }
        }
        if let error = error {
            print("File coordination failed: \(error)")
        }

        let isUbiquitous = FileManager.default.isUbiquitousItem(at: fileURL)
        print("isUbiquitousItem:\(isUbiquitous) for \(fileURL)") // FIXME：提示触发了，为什么在icloud里还是看不到
        if !isUbiquitous {
            do {
                try FileManager.default.setUbiquitous(true, itemAt: fileURL, destinationURL: fileURL)
            } catch {
                print("File setUbiquitous failed: \(error)")
            }
        }

        coordinator.coordinate(readingItemAt: fileURL, error: &error) { (newURL) in
            let exist2 = FileManager.default.fileExists(atPath: fileURL.path)
            if !exist2 {
                print("Error: not exist: \(fileURL)")
            }
            
            do {
                let contentRead = try String(contentsOf: fileURL, encoding: .utf8)
                print("File successfully read :\(contentRead) - \(fileURL)")
            } catch {
                print("Failed to read file: \(error)")
            }
        }
        
        listFilesInICloudContainer()
    }
    
    func listFilesInICloudContainer() {
        print("\n>>>>>>begin listFilesInICloudContainer")
        guard let documentsURL = presentedItemURL else {
            print("iCloud container URL is not set")
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print("Found file: \(fileURL)")
                let isUbiquitous = FileManager.default.isUbiquitousItem(at: fileURL)
                print("isUbiquitousItem:\(isUbiquitous) for \(fileURL)")
                readTextFile(at: fileURL)
            }
        } catch {
            print("Failed to list directory contents: \(error)")
        }
    }

    func readTextFile(at url: URL) {
        let coordinator = NSFileCoordinator()
        var error: NSError?
        
        coordinator.coordinate(readingItemAt: url, options: [], error: &error) { (newURL) in
            do {
                let content = try String(contentsOf: newURL, encoding: .utf8)
                print("Content of \(newURL.lastPathComponent): \(content)")
            } catch {
                print("Failed to read file: \(error)")
            }
        }
        
        if let error = error {
            print("File coordination failed: \(error)")
        }
    }
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }

    func presentedItemDidChange() {
        print("presentedItemDidChange")
    }
    
    func relinquishPresentedItem(toReader reader: @escaping ((() -> Void)?) -> Void) {
        print("relinquishPresentedItem")
        reader(nil)
    }
    
    func relinquishPresentedItem(toWriter writer: @escaping ((() -> Void)?) -> Void) {
        print("relinquishPresentedItem")
        writer(nil)
    }
    
    func savePresentedItemChanges(completionHandler: @escaping (Error?) -> Void) {
        print("savePresentedItemChanges")
        completionHandler(nil)
    }
    
    func accommodatePresentedItemDeletion(completionHandler: @escaping (Error?) -> Void) {
        print("accommodatePresentedItemDeletion")
        // Handle the file deletion
        completionHandler(nil)
    }
}

import Flutter
import UIKit
import Combine

public class FlutterDocumentProxy: NSObject, FlutterPlugin {
    public static let sharedInstance = FlutterDocumentProxy()
    public static func register(with registrar: FlutterPluginRegistrar) {
        sharedInstance.fillRootDirectorySubject()

        let channel = FlutterMethodChannel(name: "document_proxy", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(sharedInstance, channel: channel)
    }

    public var filePresenter: NSFilePresenter?
    private var rootDirectorySubject = CurrentValueSubject<URL?, NSError>(nil)
    private var cancellables = Set<AnyCancellable>()

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
        rootDirectorySubject.dropFirst().sink(receiveCompletion: { _ in }, receiveValue: { [weak self] value in
            guard let self = self else { return }
            self.filePresenter = RootDirectoryFilePresenter(presentedItemURL: value!)
            print("filePresenter has been set")
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

private class RootDirectoryFilePresenter: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue = OperationQueue()
    
    init(presentedItemURL: URL) {
        self.presentedItemURL = presentedItemURL
        super.init()
        NSFileCoordinator.addFilePresenter(self)
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

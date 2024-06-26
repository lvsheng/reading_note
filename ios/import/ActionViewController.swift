//
//  ActionViewController.swift
//  import
//
//  Created by lvsheng on 2024/5/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                    handlePDF(itemProvider: provider)
                    return
                }
            }
        }
        complete(withError: "No PDF found in action extension")
    }
    
    private func handlePDF(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { [weak self] (item, error) in
            guard let self = self else { return }
            if let error = error {
                self.complete(withError: "Error loading item: \(error.localizedDescription)")
                return
            }
            guard let fileURL = item as? URL else {
                self.complete(withError: "Invalid file URL")
                return
            }
            guard let destinationURL = copyPDF(with: fileURL) else {
                self.complete(withError: "Error Copying file")
                return
            }
            openMainApp(with: destinationURL.path)
        }
    }

    private func copyPDF(with url: URL)->URL? {
        let fileManager = FileManager.default
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.lvsheng.readingNote") {
           let containerURL = containerURL.appendingPathComponent("importing")
           let destinationURL = containerURL.appendingPathComponent("\(url.lastPathComponent)_\(Int(Date().timeIntervalSince1970 * 1000))")

           do {
               if !fileManager.fileExists(atPath: containerURL.path) {
                   try fileManager.createDirectory(atPath: containerURL.path, withIntermediateDirectories: true)
               }

               if !url.startAccessingSecurityScopedResource() {
                   print("startAccessingSecurityScopedResource fail")
               }

               try fileManager.copyItem(at: url, to: destinationURL)

               url.stopAccessingSecurityScopedResource()
               return destinationURL
           } catch {
               url.stopAccessingSecurityScopedResource()
               print("Error copying file: \(error)")
           }
       }
       return nil
    }
    
    private func openMainApp(with fileURL: String) {
        let scheme = "lsreadingnoteapp://"
        guard let encodedFileURL = fileURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),  //todo-p5:.urlHostAllowed
              let url = URL(string: "\(scheme)/import-file?path=\(encodedFileURL)") else {
            complete(withError: "Invalid URL encoding")
            return
        }
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
        while responder != nil {
            if responder!.responds(to: selectorOpenURL) {
                responder!.perform(selectorOpenURL, with: url)
                self.complete()
                return
            }
            responder = responder?.next
        }
        self.complete(withError: "Failed to open main app")
    }
    
    private func complete(withError message: String) {
        print(message)
        done()
    }
    
    private func complete() {
        print("Successfully opened main app")
        done()
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}

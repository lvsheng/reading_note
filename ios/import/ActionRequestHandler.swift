//
//  ActionRequestHandler.swift
//  import
//
//  Created by lvsheng on 2024/5/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    
    func beginRequest(with context: NSExtensionContext) {
        // Do not call super in an Action extension with no user interface
        self.extensionContext = context
        
        guard let items = context.inputItems as? [NSExtensionItem] else {
            complete(withError: "Invalid input items")
            return
        }
        
        for item in items {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                        handlePDF(itemProvider: itemProvider)
                        return
                    }
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
            guard let fileURL = item as? NSURL, let absoluteString = fileURL.absoluteString else {
                self.complete(withError: "Invalid file URL")
                return
            }
            self.openMainApp(with: absoluteString)
        }
    }
    
    private func openMainApp(with fileURL: String) {
        guard let encodedFileURL = fileURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),  //todo-p5:.urlHostAllowed
              let url = URL(string: "lsreadingnoteapp:import-file?path=\(encodedFileURL)") else {
            complete(withError: "Invalid URL encoding")
            return
        }
        
        extensionContext?.open(url, completionHandler: { success in
            if success {
                self.complete()
            } else {
                self.complete(withError: "Failed to open main app")
            }
        })
    }
    
    private func complete(withError message: String) {
        print(message)
        done()
    }
    
    private func complete() {
        print("Successfully opened main app")
        done()
    }
    
    private func done() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        extensionContext = nil
    }
}

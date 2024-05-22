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
        
        var found = false
        
        outer:
            for item in context.inputItems as! [NSExtensionItem] {
                if let attachments = item.attachments {
                    for itemProvider in attachments {
                        if itemProvider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                            itemProvider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil, completionHandler: { (item, error) in
                                if let fileURL = item as? NSURL {
                                    print(fileURL.absoluteString)
                                }
                            })
                            found = true
                            break outer
                        }
                    }
                }
        }
        
        self.done()
    }
    
    func done() {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        self.extensionContext = nil
    }
}

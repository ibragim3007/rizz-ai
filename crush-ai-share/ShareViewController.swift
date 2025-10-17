//
//  ShareViewController.swift
//  crush-ai-share
//
//  Created by Ibragim Ibragimov on 10/17/25.
//

import UIKit
import Social
import SwiftUI

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(
                rootView:
                    ShareView(itemProviders: itemProviders, extenstionContext: extensionContext)
            )
            self.addChild(hostingView)
            self.view.addSubview(hostingView.view)
            hostingView.view.translatesAutoresizingMaskIntoConstraints = false
            hostingView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            hostingView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
            hostingView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            hostingView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
        }
    }
    
    fileprivate struct ShareView: View {
        var itemProviders: [NSItemProvider]
        var extenstionContext: NSExtensionContext?
        
        var body: some View {
            VStack (spacing: 15) {
                Text("Upload a Screenshot")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Button("Cancel", action: dismiss)
                        .tint(.purple)
                    }
                Spacer(minLength: 0)
            }
            .padding(15)
        }
    
        
        func dismiss() {
            extenstionContext?.completeRequest(returningItems: [])
        }
    }

}

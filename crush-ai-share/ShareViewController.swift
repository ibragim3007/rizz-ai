//
//  ShareViewController.swift
//  crush-ai-share
//
//  Created by Ibragim Ibragimov on 10/17/25.
//

import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let itemProviders = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments else { return }
        
        let host = UIHostingController(
            rootView: ShareView(itemProviders: itemProviders, extensionContext: extensionContext)
        )
        host.view.backgroundColor = .clear
        host.additionalSafeAreaInsets = .zero
        host.view.insetsLayoutMarginsFromSafeArea = false
        host.viewRespectsSystemMinimumLayoutMargins = false
        host.view.directionalLayoutMargins = .zero
        // ВАЖНО: показываем через API композ-контроллера
        self.pushConfigurationViewController(host)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      // iOS сама ограничит максимум, но станет выше
      preferredContentSize = CGSize(width: 0, height: 560)
    }
    

    
    // Если нужно спрятать дефолтный текст/URL блок:
//    override func isContentValid() -> Bool { true }
//    override func didSelectPost() { /* не используется */ }
//    override func configurationItems() -> [Any]! { [] }
}

fileprivate struct ShareView: View {
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    @State private var items: [ImageItem] = []
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack (spacing: 15) {
                Text("Upload a Screenshot")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                
                ScrollView (.horizontal) {
                    LazyHStack (spacing: 10) {
                        ForEach(items) { item in
                            Image(uiImage: item.previewImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width)
                        }
                    }
                    .padding(.horizontal, 15)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 300)
                
                Spacer(minLength: 0)
            }
            .padding(15)
            .onAppear(perform: {
                extractItems(size: size)
            })
        }
        .padding(.zero)
        .ignoresSafeArea()
    }
    
    func extractItems(size: CGSize) {
        guard items.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            for provider in itemProviders {
                let _ = provider.loadDataRepresentation(for: .image) { data, error in
                    if let data, let image = UIImage(data: data), let thumbnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
                        DispatchQueue.main.async {
                            items.append(.init(imageData: data, previewImage: thumbnail))
                        }
                    }
                        
                }
            }
        }
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
    
    private struct ImageItem: Identifiable {
        let id: UUID = .init()
        var imageData: Data
        var previewImage: UIImage
    }
}

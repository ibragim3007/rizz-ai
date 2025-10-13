//
//  DialogScreen.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI

struct DialogScreen: View {
    var dialog: DialogEntity
    
    var body: some View {
        ZStack {
            OnboardingBackground.opacity(0.5)
            
            ScrollView {
                if let image = dialog.image {
                    LargeImageDisplay(imageEntity: image)
                        .padding(.horizontal, 10)
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem {
                    SettingsButton(destination: SettingsPlaceholderView())
                }
            }
        }
    }
}


struct LargeImageDisplay: View {
    
    var isLoading: Bool = false
    var imageEntity: ImageEntity

    private let corner: CGFloat = 24
    
    var body: some View {
        ZStack {
            content
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(AppTheme.borderPrimaryGradient, lineWidth: 1))
            
            if isLoading {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.black.opacity(0.25))
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
        .contentTransition(.opacity)
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if let url = imageEntity.localFileURL, let img = loadImage(from: url) {
                img.resizable().scaledToFill().frame(width: .infinity)
            } else if let url = imageEntity.remoteHTTPURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: placeholder
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .fill(.white.opacity(0.06))
                            ProgressView()
                                .tint(.white.opacity(0.85))
                        }
                    @unknown default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
    }
    
    private var placeholderBase: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white.opacity(0.06))
    }
    
    private var placeholder: some View {
        ZStack {
            placeholderBase
            Image(systemName: "photo")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(width: 300, height: 500)
    }
    
    private func loadImage(from url: URL) -> Image? {
        #if canImport(UIKit)
        if let ui = UIImage(contentsOfFile: url.path) { return Image(uiImage: ui) }
        #elseif canImport(AppKit)
        if let ns = NSImage(contentsOf: url) { return Image(nsImage: ns) }
        #endif
        return nil
    }
}


#Preview {
    let image = ImageEntity(id: "id", remoteUrl: "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png")
    let dialog = DialogEntity(id: "id2", userId: "u", title: "Test name")
    dialog.image = image
    return DialogScreen(dialog: dialog).preferredColorScheme(.dark)
}

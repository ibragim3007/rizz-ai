//
//  PreviewImageView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct PreviewImageView: View {
let imageEntity: ImageEntity
private let corner: CGFloat = 18

var body: some View {
    Group {
        if let url = imageEntity.localFileURL, let img = loadImage(from: url) {
            img.resizable().scaledToFill()
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
    .frame(width: 90, height: 90)
    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(AppTheme.borderPrimaryGradient, lineWidth: 1))
}

private var placeholder: some View {
    ZStack {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white.opacity(0.06))
        Image(systemName: "photo")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
    }
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

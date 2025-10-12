//
//  ScreenShotsGrid.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct ScreenShotItem: View {
    let id: String
    let imageURL: URL?
    let imageName: String?
    let title: String?
    
    init(
        id: String = UUID().uuidString,
        imagePath: String? = nil,
        title: String?
    ) {
        self.id = id
        self.imageURL = nil
        self.imageName = imagePath
        self.title = title
    }
    
    init(
        id: String = UUID().uuidString,
        imageURL: URL? = nil,
        title: String?
    ) {
        self.id = id
        self.imageURL = imageURL
        self.imageName = nil
        self.title = title
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cornerRadius: CGFloat = 16
            
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(alignment: .center) {
                    if let url = imageURL, let image = loadImage(from: url) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                    } else if let name = imageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size.width, height: size.height)
                            .clipShape(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.25), .white.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.26), .white.opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(alignment: .bottom) {
                    Text(title ?? "Unnamed")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 7)
                        .frame(width: (size.width - 10))
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .offset(y: -4)
                }
                .frame(width: size.width, height: size.height)
        }
        .aspectRatio(0.618, contentMode: .fit)
    }
    
    private func loadImage(from url: URL) -> Image? {
        #if canImport(UIKit)
        if let uiImage = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: uiImage)
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(contentsOf: url) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
}


#Preview {
    ScreenShotItem(imagePath: "sample-screen", title: "Karla from college").preferredColorScheme(.dark)
}


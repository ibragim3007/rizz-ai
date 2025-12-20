//
//  ScreenShotsGrid.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

private final class ImageMemoryCache {
    static let shared = ImageMemoryCache()
#if canImport(UIKit)
    private let cache = NSCache<NSString, UIImage>()
    func image(forKey key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ image: UIImage, forKey key: String) { cache.setObject(image, forKey: key as NSString) }
#elseif canImport(AppKit)
    private let cache = NSCache<NSString, NSImage>()
    func image(forKey key: String) -> NSImage? { cache.object(forKey: key as NSString) }
    func set(_ image: NSImage, forKey key: String) { cache.setObject(image, forKey: key as NSString) }
#endif
}

struct ScreenShotItem: View {
    let id: String
    let imageURL: URL?
    let imageName: String?
    let title: String?
    
    @State private var loadedImage: Image?

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
                .fill(.white.opacity(0.1))
                .overlay(alignment: .center) {
                    if let image = loadedImage {
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
                            .transition(.opacity)
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
                    let hasTitle = !(title?.isEmpty ?? true)
                    let displayTitle = hasTitle ? title! : "Not named"
                    
                    if hasTitle {
                        Text(displayTitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .opacity(hasTitle ? 1.0 : 0.5)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 7)
                            .frame(width: (size.width - 10))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .offset(y: -4)
                    }
                }
                .frame(width: size.width, height: size.height)
        }
        .aspectRatio(0.62, contentMode: .fit)
        .task(id: imageURL) {
            await loadIfNeeded()
        }
        .onAppear {
            // Быстрая подстановка из кэша, если есть
            if loadedImage == nil {
                Task { await loadIfNeeded() }
            }
        }
        .contentTransition(.opacity)
    }
    
    @MainActor
    private func setLoaded(_ image: Image?) {
        withAnimation(.easeIn(duration: 0.15)) {
            self.loadedImage = image
        }
    }
    
    private func loadIfNeeded() async {
        guard let url = imageURL else {
            await MainActor.run { setLoaded(nil) }
            return
        }
        // Попробовать из кэша
        #if canImport(UIKit)
        if let cached = ImageMemoryCache.shared.image(forKey: url.path) {
            await MainActor.run { setLoaded(Image(uiImage: cached)) }
            return
        }
        #elseif canImport(AppKit)
        if let cached = ImageMemoryCache.shared.image(forKey: url.path) {
            await MainActor.run { setLoaded(Image(nsImage: cached)) }
            return
        }
        #endif
        
        // Загрузка и декодирование вне главного потока
        let imageResult: Image? = await Task.detached(priority: .userInitiated) { () -> Image? in
            #if canImport(UIKit)
            guard let ui = UIImage(contentsOfFile: url.path) else { return nil }
            await ImageMemoryCache.shared.set(ui, forKey: url.path)
            return Image(uiImage: ui)
            #elseif canImport(AppKit)
            guard let ns = NSImage(contentsOf: url) else { return nil }
            ImageMemoryCache.shared.set(ns, forKey: url.path)
            return Image(nsImage: ns)
            #else
            return nil
            #endif
        }.value
        
        await MainActor.run {
            setLoaded(imageResult)
        }
    }
}

#Preview {
    ScreenShotItem(imagePath: "sample-screen", title: "Karla from college")
}

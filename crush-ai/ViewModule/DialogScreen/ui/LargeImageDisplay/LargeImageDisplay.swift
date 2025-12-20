//
//  LargeImageDisplay.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/25/25.
//

import SwiftUI

struct LargeImageDisplay: View {
    
    var isLoading: Bool = false
    var imageEntity: ImageEntity
    
    private let corner: CGFloat = 24
    
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    
    // Состояние анимации «сканирования»
    @State private var startScan = false
    
    var body: some View {
        ZStack {
            content
                .modifier(RippleEffect(at: origin, trigger: counter))
                .onTapGesture { location in
                    origin = location
                    counter += 1
                }
            
            
            if isLoading {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.black.opacity(0.25))
                    .overlay {
                        ZStack {
                            // Лёгкая сетка как намёк на «анализ»
                            GeometryReader { geo in
                                let spacing: CGFloat = 22
                                Canvas { context, size in
                                    var path = Path()
                                    // Вертикальные линии
                                    var x: CGFloat = 0
                                    while x <= size.width {
                                        path.move(to: CGPoint(x: x, y: 0))
                                        path.addLine(to: CGPoint(x: x, y: size.height))
                                        x += spacing
                                    }
                                    // Горизонтальные линии
                                    var y: CGFloat = 0
                                    while y <= size.height {
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: size.width, y: y))
                                        y += spacing
                                    }
                                    context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 0.5)
                                }
                                .blendMode(.plusLighter)
                                .allowsHitTesting(false)
                                
                                // Двигающийся «луч» сканирования
                                let beamHeight = max(40, geo.size.height * 0.18)
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.35),
                                        .white.opacity(0.55),
                                        .white.opacity(0.35),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: beamHeight)
                                .blur(radius: 6)
                                .mask(
                                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                                        .fill(.white)
                                )
                                .offset(y: startScan ? geo.size.height + beamHeight : -beamHeight)
                                .animation(
                                    .easeInOut(duration: 1.6)
                                    .repeatForever(autoreverses: false),
                                    value: startScan
                                )
                            }
                            
                            // Угловые маркеры
                            CornerMarks(cornerRadius: corner)
                                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: 0)
                                .blendMode(.plusLighter)
                            
                            // Центр. индикатор
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.1)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                        .onAppear { startScan = true }
                        .onDisappear { startScan = false }
                    }
            }
        }
        .contentTransition(.opacity)
    }
    
    // Type-erased to keep the compiler happy across branches
    private var content: some View {
        Group {
            if let url = imageEntity.localFileURL, let img = loadImage(from: url) {
                AnyView(
                    img
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: 450)
                )
            } else if let url = imageEntity.remoteHTTPURL {
                AnyView(
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            AnyView(
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 450)
                            )
                        case .failure:
                            AnyView(placeholder)
                        case .empty:
                            AnyView(
                                ZStack {
                                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                                        .fill(.white.opacity(0.06))
                                    ProgressView()
                                        .tint(.white.opacity(0.85))
                                }
                            )
                        @unknown default:
                            AnyView(placeholder)
                        }
                    }
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                )
            } else {
                AnyView(placeholder)
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
    
    let image = ImageEntity(
        id: "id",
        remoteUrl: "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png"
    )
    LargeImageDisplay(isLoading: false, imageEntity: image)
}

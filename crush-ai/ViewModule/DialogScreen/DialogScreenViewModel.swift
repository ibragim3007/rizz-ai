//
//  DialogScreenView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

@MainActor
final class DialogScreenViewModel: ObservableObject {
    @Published var currentImageUrl: URL
    @Published var context: String?
    
    init(currentImageUrl: URL, context: String? = nil) {
        self.currentImageUrl = currentImageUrl
        self.context = context
        
        let _ = DialogScreenViewModel.makeBase64(from: currentImageUrl)
    }
    
    func getReply () {
        print("Get reply")
    }
    
    /// Создает Base64-строку из изображения по URL с возможным даунскейлом и JPEG-сжатием.
    /// - Parameters:
    ///   - url: Локальный или удаленный URL изображения.
    ///   - downscaleFactor: Во сколько раз уменьшить ширину/высоту. 0.6 = 60% от исходного.
    ///   - jpegQuality: Качество JPEG перекодирования (0.0...1.0). 0.6 ~ «сжать на 40%».
    /// - Returns: Base64 строка или пустая строка при неудаче.
    static func makeBase64(from url: URL?, downscaleFactor: CGFloat = 0.6, jpegQuality: CGFloat = 0.6) -> String {
        guard let url else { return "" }
        
        // Загружаем байты (локально или по сети)
        guard let data = try? Data(contentsOf: url) else {
            return ""
        }
        
        // Пытаемся загрузить в платформенное изображение
        #if canImport(UIKit)
        guard let image = UIImage(data: data) ?? UIImage(contentsOfFile: url.path) else {
            // Если не удалось распарсить как изображение — отправим как есть
            return data.base64EncodedString()
        }
        
        // Даунскейл
        let targetSize = CGSize(width: image.size.width * downscaleFactor,
                                height: image.size.height * downscaleFactor)
        let format = UIGraphicsImageRendererFormat()
        // Сохраняем масштаб экрана, чтобы корректно получить пиксели
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // JPEG перекодирование
        if let jpeg = scaledImage.jpegData(compressionQuality: jpegQuality) {
            return jpeg.base64EncodedString()
        } else {
            // Фолбэк — исходные байты
            return data.base64EncodedString()
        }
        
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) ?? NSImage(contentsOf: url) else {
            return data.base64EncodedString()
        }
        
        // Даунскейл NSImage
        let scaled = NSImage(size: NSSize(width: nsImage.size.width * downscaleFactor,
                                          height: nsImage.size.height * downscaleFactor))
        scaled.lockFocus()
        nsImage.draw(in: NSRect(origin: .zero, size: scaled.size),
                     from: NSRect(origin: .zero, size: nsImage.size),
                     operation: .copy,
                     fraction: 1.0)
        scaled.unlockFocus()
        
        guard let tiff = scaled.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: jpegQuality])
        else {
            return data.base64EncodedString()
        }
        return jpeg.base64EncodedString()
        #else
        // Неизвестная платформа — отправим как есть
        return data.base64EncodedString()
        #endif
    }
}


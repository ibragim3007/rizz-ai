//
//  ColorExtenstion.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI


extension Color {
    /// Быстрый hex-инициализатор (0xRRGGBB)
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b).opacity(alpha)
    }
    
    /// Подкрутка насыщенности/яркости от исходного цвета (через HSB).
    /// Положительное значение увеличивает параметр, отрицательное — уменьшает.
    func tune(saturation ds: CGFloat = 0.0, brightness db: CGFloat = 0.0) -> Color {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }
        let ns = max(0.0, min(1.0, s + ds))
        let nb = max(0.0, min(1.0, b + db))
        return Color(UIColor(hue: h, saturation: ns, brightness: nb, alpha: a))
        #else
        return self
        #endif
    }
}

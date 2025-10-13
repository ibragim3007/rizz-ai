//
//  AppTheme.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

// MARK: - Theme (меняешь только primaryBase)

enum AppTheme {
    // Задай здесь любой цвет бренда — всё остальное адаптируется
    static let primaryBase: Color = Color("Primary") // фиолетовый по умолчанию
    static let backgroundBase: Color = Color("Background")
    
    // Производные оттенки и эффекты
    static var primary: Color { primaryBase }
    static var primaryLight: Color { primaryBase.tune(saturation: -0.15, brightness: 0.20) }
    static var primaryDark: Color { primaryBase.tune(saturation: 0.10, brightness: -0.25) }
    static var glow: Color { primaryBase.tune(saturation: 0.00, brightness: 0.35) }
    
    static var background: Color { backgroundBase }
    
    // Градиенты
    static var primaryGradient: LinearGradient {
        LinearGradient(colors: [primary, primaryLight], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static var borderPrimaryGradient: LinearGradient {
        LinearGradient(colors: [.white.opacity(0.26), .white.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // Фоновые цвета
    static let backgroundTop = Color.black
    static let backgroundBottom = Color(red: 3/255, green: 3/255, blue: 6/255)
    
    // Интенсивности (можно подкрутить при желании)
    static let auraCenterOpacity: Double = 0.35
    static let auraBottomOpacity: Double = 0.75
}

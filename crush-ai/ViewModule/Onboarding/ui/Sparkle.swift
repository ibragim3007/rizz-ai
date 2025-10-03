//
//  Sparkle.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI


func sparkle(at point: CGPoint, size: CGFloat, delay: Double, phase: CGFloat) -> some View {
    Image(systemName: "sparkle")
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(AppTheme.primaryGradient)
        .frame(width: size, height: size)
        .position(point)
        .opacity(0.7)
        .scaleEffect(0.9 + 0.2 * sin((phase + CGFloat(delay)) * .pi * 2))
        .shadow(color: AppTheme.primary.opacity(0.6), radius: 8, x: 0, y: 0)
}


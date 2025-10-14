//
//  GradientButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct PrimaryGradientButtonStyleShimmer: ButtonStyle {
    var isShimmering: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    
    var cornerRadius: CGFloat = 26
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.primaryGradient)
                    .shadow(
                        color: AppTheme.primary.opacity(
                            configuration.isPressed ? 0.18 : 0.38
                        ),
                        radius: configuration.isPressed ? 10 : 20,
                        x: 0,
                        y: configuration.isPressed ? 6 : 12
                    )
            ).overlay {
                isShimmering
                ? ShimmerMask()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: cornerRadius,
                            style: .continuous
                        )
                    )
                    .opacity(configuration.isPressed ? 0.0 : 0.6)
                : nil
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .saturation(isEnabled ? 1 : 0)
            .animation(
                .spring(response: 0.26, dampingFraction: 0.85),
                value: configuration.isPressed
            )
    }
}

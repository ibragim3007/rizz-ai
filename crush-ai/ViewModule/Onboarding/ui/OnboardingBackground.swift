//
//  OnboardingBackground.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

var OnboardingBackground: some View {
    return ZStack {
        // Дополнительная “аура” по центру
        RadialGradient(
            gradient: Gradient(colors: [
                AppTheme.primary.opacity(AppTheme.auraCenterOpacity),
                .clear
            ]),
            center: .center,
            startRadius: 10,
            endRadius: 420
        )
        .blendMode(.plusLighter)
        .ignoresSafeArea()
    }
}

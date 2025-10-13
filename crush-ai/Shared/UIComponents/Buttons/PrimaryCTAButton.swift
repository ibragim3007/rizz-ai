//
//  DefaultButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct PrimaryCTAButton: View {
    let title: LocalizedStringKey
    let isShimmering: Bool
    let height: CGFloat
    let font: Font
    let fullWidth: Bool
    let action: () -> Void

    init(
        title: LocalizedStringKey,
        isShimmering: Bool? = nil,
        height: CGFloat = 60,
        font: Font = .system(size: 20, weight: .semibold, design: .rounded),
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isShimmering = isShimmering ?? false
        self.height = height
        self.font = font
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: height)
                .contentShape(Rectangle())
        }
        .buttonStyle(PrimaryGradientButtonStyleShimmer(isShimmering: isShimmering))
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryCTAButton(title: "Get Started", isShimmering: false) {
            // preview action
        }
        .padding(.horizontal, 20)

        PrimaryCTAButton(
            title: "Custom Width",
            height: 52,
            font: .system(size: 18, weight: .semibold, design: .rounded),
            fullWidth: false
        ) {
            // preview action
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}

//
//  ToneButtonView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct ToneButtonView: View {
    var body: some View {
        Button(action: {
            print("Change tone")
        }) {
            Text("⚡️")
                .font(.system(size: 20, weight: .semibold))
//                .frame(width: 44, height: 44)
//                .contentShape(Circle())
        }
        .buttonStyle(.plain)
//        .background(
//            Circle()
//                .fill(AppTheme.primary.opacity(0.20))
//        )
//        .overlay(
//            Circle()
//                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
//        )
//        .clipShape(Circle())
//        .shadow(color: AppTheme.glow.opacity(0.25), radius: 8, x: 0, y: 4)
        .accessibilityLabel("Change tone")
        .accessibilityAddTraits(.isButton)
    }
}


#Preview {
    ZStack {
        OnboardingBackground
        ToneButtonView()
    }
}

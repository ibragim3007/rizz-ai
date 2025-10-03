//
//  OnboardingHeader.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct OnboardingHeader: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        HStack {
            Spacer()
            Button("Skip") {
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                viewModel.skipToEnd()
            }
            .buttonStyle(GlassButtonStyle())
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
//            .frame(width: 60, height: 44, alignment: .trailing)
            .accessibilityLabel("Skip onboarding")
        }
        .padding(.top, 12)
    }
}

//
//  PageIndicator.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct PageIndicator: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.steps.indices, id: \.self) { index in
                let isActive = index == viewModel.currentIndex
                Capsule()
                    .fill(isActive ? AppTheme.primary : .white.opacity(0.25))
                    .frame(width: isActive ? 18 : 6, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.currentIndex)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 8)
        .accessibilityLabel("Page \(viewModel.currentIndex + 1) of \(viewModel.steps.count)")
    }
    
}

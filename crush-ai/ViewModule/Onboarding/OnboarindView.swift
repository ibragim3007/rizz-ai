//
//  OnboarindView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject var viewModel = OnboardingViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        ZStack {
            OnboardingBackground
            VStack(spacing: 0) {
                OnboardingHeader(viewModel: viewModel).padding(.horizontal, 24)
                OnboardingPager(viewModel: viewModel)
                PageIndicator(viewModel: viewModel)
                footerButton.padding(.horizontal, 24)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: viewModel.currentIndex)
        .accessibilityElement(children: .contain)
    }
    
    var buttonTitle: LocalizedStringKey {
        if viewModel.steps.count <= 1 { return "Get Started" }
        return viewModel.isLast ? "Finish" : (viewModel.currentIndex == 0 ? "Get Started" : "Next")
    }
    
    func onPrimaryButtonTap() {
        if viewModel.isLast {
            hasSeenOnboarding = true
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                viewModel.next()
            }
        }
    }

    
}

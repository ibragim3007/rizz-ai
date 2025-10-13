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
            VStack(spacing: 7) {
//                OnboardingHeader(viewModel: viewModel).padding(.horizontal, 24)
                OnboardingPager(viewModel: viewModel)
//                PageIndicator(viewModel: viewModel)
                
                // Кнопку не удаляем — плавно прячем/показываем
                footerButton
                    .padding(.horizontal, 24)
                    .opacity(showFooter ? 1 : 0)
                    .offset(y: showFooter ? 0 : 80)
                    .allowsHitTesting(showFooter)
                    .accessibilityHidden(!showFooter)
                    .animation(.spring(response: 0.45, dampingFraction: 0.9), value: showFooter)
            }
        }
        .background(AppTheme.background)
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: viewModel.currentIndex)
        .accessibilityElement(children: .contain)
        .task {
            await viewModel.loginUser()
        }
    }
    
    // Показываем футер только на «фичах» и т.п., скрываем на вопросах и лоадере
    private var showFooter: Bool {
        switch viewModel.getCurrentPage().kind {
        case .question, .smallLoader:
            return false
        default:
            return true
        }
    }
    
    var buttonTitle: LocalizedStringKey {
        if viewModel.steps.count <= 1 { return "Get Started" }
        return viewModel.isLast ? "Finish" : (viewModel.currentIndex == 0 ? "Get Started" : "Next")
    }
    
    func onPrimaryButtonTap() {
#if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
        
        if viewModel.isLast {
            hasSeenOnboarding = true
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                viewModel.next()
            }
        }
    }
    
}

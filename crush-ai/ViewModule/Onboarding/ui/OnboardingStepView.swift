//
//  OnboardingStepView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct OnboardingStepView: View {
    @ObservedObject var viewModel : OnboardingViewModel
    let kind: OnboardingStepKind
    let illustration: AnyView?
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            switch kind {
            case let .feature(title, highlightText, subtitle, imageName):
                FeatureUI(title: title, highlightText: highlightText, subtitle: subtitle, imageName: imageName, illustration: illustration)
                
            case .permissionNotifications: PermissionNotification()
                
            case let .rateUsPage(title, subtext, icon):
                RateUsUI(title: title, subtext: subtext, icon: icon)
            
            case let .smallLoader(title, duration):
                SmallLoader(title: title, duration: TimeInterval(duration)) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    // Завершаем онбординг по окончании загрузки
//                    hasSeenOnboarding = true
                    viewModel.next()
                }
                
            case let .statistics(title, description):
                StatisticsContent()

            case let .question(title, subtitle, variants):
                QuestionTemplate(title: title, subtext: subtitle, variants: variants)  {variant in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.next()
                }
            }
            
            Spacer(minLength: 0)
        }
    }
}


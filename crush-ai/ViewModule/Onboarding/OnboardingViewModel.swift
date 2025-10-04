//
//  OnboardingViewModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    
    // Для данного дизайна — один шаг. Архитектура сохранена.
    @Published var steps: [OnboardingStep] = [
        .init(
            kind: .feature(
                title: "Not Getting Enough",
                highlightText: "Replies?",
                subtitle: "Messages getting ignored? Let us craft standout replies—no more being left on read!",
                imageName: ""
            ),
            illustration: AnyView(MessageBubbles()),
            illustrationKey: "MessageBubbles"
        ),
        .init(kind: .feature(
            title: "Your First Message Is",
            highlightText: "Everything",
            subtitle: "Over 60% of matches never get pass that crucial opener. Don't let yours fall flat",
            imageName: "first-message"
        )),
        .init(kind: .question(title: "What's your age?", subtitle: "Let us personalize your experiance", variants: ["Under 18", "18-22", "22-31", "32-41", "41-51", "51-56", "over 56"])),
        .init(kind: .question(title: "I'm looking for...", subtitle: "This question will help us determine how to help you ideally", variants: ["🏡 Serious", "🤪 Casual", "💍 Marriage", "😈 Flirt" ,"🤔 Not decided"]))
    ]
    
    func getCurrentPage() -> OnboardingStep {
        let currentPage: OnboardingStep = steps[currentIndex]
        
        return currentPage
    }
    
    var isLast: Bool { currentIndex == steps.count - 1 }
    
    func next() {
        guard currentIndex < steps.count - 1 else { return }
        currentIndex += 1
    }
    
    func skipToEnd () {
        currentIndex = steps.count - 1
    }
}

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
                title: "Tired of being",
                highlightText: "left on read?",
                subtitle: "Keep the energy up with replies that actually move things forward",
                imageName: ""
            ),
            illustration: AnyView(MessageBubbles()),
            illustrationKey: "MessageBubbles"
        ),

        .init(kind: .feature(
            title: "Your First Message Is",
            highlightText: "Everything",
            subtitle: "Open with a line that sounds like you and gets a real reply.",
            imageName: "",
        ), illustration: AnyView(SecondScreenContent())),

        .init(kind: .question(title: "What's your age?", subtitle: "Let us personalize your experiance", variants: ["Under 18", "18-22", "22-31", "32-41", "41-51", "51-56", "over 56"])),

        .init(kind: .question(title: "I'm looking for...", subtitle: "This question will help us determine how to help you ideally", variants: ["🏡 Serious", "🤪 Casual", "💍 Marriage", "😈 Flirt" ,"🤔 Not decided"])),

        .init(kind: .question(title: "How many of your chats get a reply?", subtitle: "", variants: ["💔 Not event 1", "😐 1-3", "🥉 4-6", "🥈 7-12" ,"🥇 13+"])),

        .init(kind: .question(title: "What’s your biggest roadblock in chats?", subtitle: "", variants: ["🤔 I don’t know what to write first", "💭 I get stuck after they reply", "🥱 My questions are boring", "☕️ I move to a date too late" ,"🛟 Other"])),
        
            .init(kind: .smallLoader(title: "Analyzing your info", duration: 6))
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

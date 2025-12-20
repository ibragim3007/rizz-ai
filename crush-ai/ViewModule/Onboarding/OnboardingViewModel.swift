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
        .init(kind: .feature( title: "Tired of being", highlightText: "left on read?", subtitle: "Keep the energy up with replies that actually move things forward", imageName: "" ), illustration: AnyView(MessageBubbles()), illustrationKey: "MessageBubbles"),
        .init(kind: .feature(title: "Your First Message Is", highlightText: "Everything", subtitle: "Open with a line that sounds like you and gets a real reply.", imageName: "", ), illustration: AnyView(SecondScreenContent())),
        .init(kind: .rateUsPage(title: "Help us Grow", subtext: "How useful does this look now?", icon: "app-icon")),
        .init(kind: .question(title: "What's your age?", subtitle: "I’ll adjust your tone and flirty level", variants: ["I’m under 18","18-24", "25–34", "35–44", "45–54", "55+"])),
        .init(kind: .question(title: "What’s your goal here?", subtitle: "This question will help us determine how to help you ideally", variants: ["💞 Real connection", "😜 Fun & light", "💎 Long-term", "😈 Flirty only" ,"🤔 Not sure yet"])),
        .init(kind: .feature(title: "Make Them Feel", highlightText: "Seen", subtitle: "Paste their message. Get the perfect reply in seconds.", imageName: "", ), illustration: AnyView(BeforeAfterContent())),
        .init(kind: .question(title: "How many of your chats get a reply?", subtitle: "", variants: ["💔 Almost never", "😕 1–3 replies", "🙂 4–6 replies", "😎 7–12 replies" ,"🏆 13+ replies"])),
        .init(kind: .question(title: "What’s your biggest roadblock in chats?", subtitle: "", variants: ["🤔 First line?", "💭 Stuck after reply", "🥱 Boring questions", "☕️ Date too late" ,"🛟 Other"])),
        .init(kind: .smallLoader(title: "Analyzing your info", duration: 7)),
        .init(kind: .statistics(title: "Wingman AI Can increase your dates 7x times more", description: "Starting today, you can get more girls than ever before. The point is, it really does make your life easier: more original and personalized responses equal more dates."))
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
    
    func loginUser() async {
        do {
            let appToken = await TokenService.shared.getOrCreateAppToken()
            let authRequestBody = AuthRequest(appToken: appToken)
            
            // ВАЖНО: передаём конкретный тип, без as? Encodable
            let authResponse: AuthResponse = try await APIClient.shared.request(
                endpoint: "/auth/login",
                method: .post,
                body: authRequestBody,
                headers: nil
            )
            
            print("Login successful! " + authResponse.user.id)
        } catch {
            print("Login failed: \(error)")
        }
    }
}

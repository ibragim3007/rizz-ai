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
                imageName: "phone.mock"
            ),
            illustration: AnyView(MessageBubbles()),
            illustrationKey: "MessageBubbles"
        ),
        .init(kind: .feature(
            title: "Not Getting Enough",
            highlightText: "Replies?",
            subtitle: "Messages getting ignored? Let us craft standout replies—no more being left on read!",
            imageName: "phone.mock"
        ))
    ]
    
    var isLast: Bool { currentIndex == steps.count - 1 }
    
    func next() {
        guard currentIndex < steps.count - 1 else { return }
        currentIndex += 1
    }
    
    func skipToEnd () {
        currentIndex = steps.count - 1
    }
}

//
//  OnboardingModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import Foundation
import SwiftUI

enum OnboardingStepKind: Equatable {
    case feature(title: String, highlightText: String, subtitle: String, imageName: String)
    case question(title: String, subtitle: String, variants: [String])
    case permissionNotifications
    case rateUsPage(title: String, subtext: String, icon: String)
    case smallLoader (title: String, duration: Int)
    case statistics (title: String, description: String)
}

struct OnboardingStep: Identifiable, Equatable {
    let id: UUID
    let kind: OnboardingStepKind
    
    // Любая картинка/иллюстрация/кастомный View
    let illustration: AnyView?
    // Необязательный ключ для сравнения (если хотите учитывать тип иллюстрации)
    let illustrationKey: String?

    init(
        id: UUID = UUID(),
        kind: OnboardingStepKind,
        illustration: AnyView? = nil,
        illustrationKey: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.illustration = illustration
        self.illustrationKey = illustrationKey
    }

    // Сравниваем только данные шага и ключ иллюстрации
    static func == (lhs: OnboardingStep, rhs: OnboardingStep) -> Bool {
        lhs.kind == rhs.kind && lhs.illustrationKey == rhs.illustrationKey
    }
}

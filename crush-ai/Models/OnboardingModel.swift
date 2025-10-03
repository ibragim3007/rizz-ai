//
//  OnboardingModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import Foundation

enum OnboardingStepKind: Equatable {
    case feature(title: String, highlightText: String, subtitle: String, imageName: String)
    case permissionNotifications
}


struct OnboardingStep: Identifiable, Equatable {
    let id = UUID()
    let kind: OnboardingStepKind
}

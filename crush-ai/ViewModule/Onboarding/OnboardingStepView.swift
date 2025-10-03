//
//  OnboardingStepView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct OnboardingStepView: View {
    let kind: OnboardingStepKind
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            switch kind {
            case let .feature(title, subtitle, imageName):
                VStack(spacing: 12) {
                    // Иллюстрация/мок телефона
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                        .accessibilityHidden(true)
                    
                    VStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 330)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                }
                
            case .permissionNotifications:
                VStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.primary.opacity(0.5), radius: 18, x: 0, y: 8)
                        .accessibilityHidden(true)
                    
                    Text("Stay in the loop")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Enable notifications to get timely tips and replies that boost your conversations.")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
            }
            
            Spacer(minLength: 0)
        }
    }
}

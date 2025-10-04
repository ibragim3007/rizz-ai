//
//  OnboardingStepView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct OnboardingStepView: View {
    let kind: OnboardingStepKind
    let illustration: AnyView?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            switch kind {
            case let .feature(title, highlightText, subtitle, _):
                VStack(spacing: 0) {
                    if let illustration = illustration {
                        illustration
                    }
                    Spacer()
                    
                    //                    if !imageName.isEmpty {
                    //                        Image(imageName)
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(maxWidth: 320)
                    //                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                    //                            .accessibilityHidden(true)
                    //                    }
                    //
                    VStack(spacing: 10) {
                        VStack {
                            Text(title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 4)
                            
                            Text(highlightText)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primaryGradient)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
                                .shadow(color: AppTheme.primary.opacity(0.5), radius: 11)
                        }
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 330)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                }
                
//            case .question:
//                VStack { QuestionTemplate() }
//                
//                
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
                
            case let .question(title, subtitle, variants):
                QuestionTemplate()
            }
            
            Spacer(minLength: 0)
        }
    }
}

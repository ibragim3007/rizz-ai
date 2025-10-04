//
//  QuestionTemplate.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct QuestionTemplate: View {
    
    let title: String
    let subtext: String
    let variants: [String]
    let onAction: (_ variant: String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(subtext)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
            
            // Options
            
                VStack(spacing: 16) {
                    ForEach(variants, id: \.self) { variant in
                        Button {
                            onAction(variant)
                        } label: {
                            HStack {
                                Text(variant)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(ChoiceButtonBackground())
                        }
                        .buttonStyle(.plain)
                        .shadow(color: AppTheme.glow.opacity(0.25), radius: 15, x: 0, y: 8)
                        .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: 12)
                    }
                }
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
//        .padding(.bottom, 24)
        // Фон не задаём — он приходит сверху.
    }
}

private struct ChoiceButtonBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(AppTheme.primaryGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.28),
                                .white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

#Preview {
    ZStack {
        // Только для превью
        LinearGradient(
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        QuestionTemplate(
            title: "What’s your age?",
            subtext: "Let us personalize your experience",
            variants: ["Under 18", "18–24", "25–34", "35–44", "45–55", "Over 55"],
            onAction: { print("Selected: \($0)") }
        )
    }
    .preferredColorScheme(.dark)
}

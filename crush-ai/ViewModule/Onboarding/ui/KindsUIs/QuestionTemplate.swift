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
    
    @State private var showOptions: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .multilineTextAlignment(.center)
                
                Text(subtext)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 4)
            
            // Options (compact rows with glass background)
            VStack(spacing: 12) {
                ForEach(Array(variants.enumerated()), id: \.element) { index, variant in
                    Button {
                        onAction(variant)
                    } label: {
                        HStack(spacing: 12) {
                            Text(variant)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(OptionRowButtonStyle())
                    // Каскадное появление
                    .opacity(showOptions ? 1 : 0)
                    .offset(y: showOptions ? 0 : 10)
                    .animation(
                        .spring(response: 0.38, dampingFraction: 0.9, blendDuration: 0.2)
                            .delay(0.06 * Double(index)),
                        value: showOptions
                    )
                }
            }
            .padding(.top, 4)
            // Триггерим появление при первом показе и при смене вариантов
            .task(id: variants) {
                showOptions = false
                await Task.yield()
                showOptions = true
            }
        }
        .foregroundColor(AppTheme.fontMain)
        .padding(.horizontal, 20)
        // Фон не задаём — он приходит сверху.
    }
}

// MARK: - Compact Row ButtonStyle

private struct OptionRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    // лёгкий тинт фирменным цветом
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.primary.opacity(configuration.isPressed ? 1 : 0.9))
                    )
                    // тонкий «стеклянный» штрих
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.52), .white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

// Оставим, если пригодится в других местах проекта
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
        QuestionTemplate(
            title: "What’s your age?",
            subtext: "Let us personalize your experience",
            variants: ["Under 18", "18–24", "25–34", "35–44", "45–55", "Over 55"],
            onAction: { print("Selected: \($0)") }
        )
        .padding(.vertical, 24)
    }
}

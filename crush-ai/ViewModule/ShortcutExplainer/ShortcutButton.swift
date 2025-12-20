//
//  ShortcutButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/24/25.
//

import SwiftUI

struct ShortcutButton: View {
    
    // Локальный стейт для показа шита с объяснением шортката
    @State private var showExplainerSheet: Bool = false
    
    var body: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            withAnimation(.spring(response: 0.32, dampingFraction: 0.9, blendDuration: 0.2)) {
                showExplainerSheet = true
            }
        } label: {
            HStack(spacing: 22) {
                // Shortcuts‑style glyph
                ZStack {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 36, height: 36)
                        .shadow(color: .purple.opacity(0.18), radius: 6, x: 0, y: 3)
                    Image("apple-shortcut-icon")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("Add “Get Reply” Shortcut", comment: "Add Get Reply shortcut button"))
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(NSLocalizedString("Opens the Shortcuts app to install it.", comment: "Subtitle explaining the shortcut action"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString("Add Get Reply shortcut", comment: "Accessibility label for adding shortcut"))
        .accessibilityHint(NSLocalizedString("Opens the explainer to install the shortcut.", comment: "Accessibility hint for adding shortcut"))
        // Презентация как bottom sheet на 70% экрана
        .sheet(isPresented: $showExplainerSheet) {
            ShortcutExplainer {
                // Закрываем шит по нажатию "Let’s start"
                withAnimation(.spring(response: 0.32, dampingFraction: 0.95, blendDuration: 0.2)) {
                    showExplainerSheet = false
                }
            }
            .preferredColorScheme(.dark)
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
            .applyDetents70()
        }
    }
}

// Вспомогательный модификатор: применяем detents только там, где доступно
private extension View {
    @ViewBuilder
    func applyDetents70() -> some View {
        if #available(iOS 16.0, *) {
            self
                // Добавляем возможность развернуть до полной высоты
                .presentationDetents([.fraction(1), .large])
                // Интеракцию с фоном оставляем доступной только до 0.8
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(1)))
        } else {
            self
        }
    }
}

#Preview {
    ShortcutButton()
}

//
//  GlassButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct GlassButton<Content: View>: View {
    
    // Основные параметры
    private let action: () -> Void
    
    // Состояние загрузки и блокировки
    private let isLoading: Bool
    private let isDisabled: Bool
    
    // Контент кнопки (текст, Label или любой View)
    private let contentBuilder: () -> Content
    
    // Для доступности — если используем текстовый init, пробрасываем label автоматически
    private let accessibilityLabelText: String?
    
    // Базовый инициализатор с любым контентом
    init(
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.contentBuilder = content
        self.accessibilityLabelText = accessibilityLabel
    }
    
    // Удобный инициализатор для текста (совместим с прежними вызовами)
    init(
        action: @escaping () -> Void,
        text: String,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) where Content == Text {
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.accessibilityLabelText = text
        self.contentBuilder = {
            Text(text)
                .fontWeight(.bold)
                .font(.system(size: 20))
        }
    }
    
    // Сохранённая совместимость с старым сигнатурным init(action:text, isLoading:)
    init(
        action: @escaping () -> Void,
        text: String,
        isLoading: Bool
    ) where Content == Text {
        self.init(action: action, text: text, isLoading: isLoading, isDisabled: false)
    }
    
    var body: some View {
        Button(action: action, label: {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primary)
                } else {
                    contentBuilder()
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .disabled(isLoading || isDisabled)
        .opacity(isLoading || isDisabled ? 0.6 : 1.0)
        .modifier(ConditionalAccessibilityLabel(label: accessibilityLabelText))
        .accessibilityHint(Text(isLoading ? "Downloading" : "Some Action"))
    }
}

// Вспомогательный модификатор для условной установки accessibilityLabel
private struct ConditionalAccessibilityLabel: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(Text(label))
        } else {
            content
        }
    }
}

//
//  GlassButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct GlassButton: View {
    
    // Основные параметры
    private let action: () -> Void
    private let text: String
    
    // Состояние загрузки и блокировки
    private var isLoading: Bool
    private let isDisabled: Bool
    
    init(action: @escaping () -> Void,
         text: String) {
        self.action = action
        self.text = text
        self.isLoading = false
        self.isDisabled = false
    }
    
    init(action: @escaping () -> Void,
         text: String, isLoading: Bool = false) {
        self.action = action
        self.text = text
        self.isLoading = false
        self.isDisabled = false
    }
    
    var body: some View {
        Button(action: action, label: {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.primary)
                } else {
                    Text(text)
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        })
        .buttonStyle(.plain)
        .disabled(isLoading || isDisabled)
        .opacity(isLoading || isDisabled ? 0.6 : 1.0)
        .accessibilityLabel(Text(text))
        .accessibilityHint(Text(isLoading ? "Загрузка" : "Действие"))
    }
}

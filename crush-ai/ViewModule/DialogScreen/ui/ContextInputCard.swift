//
//  ContextInputCard.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI

struct ContextInputCard: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    private let corner: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Extra context")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary.opacity(0.5))
                .padding(.leading, 6)
                .accessibilityHidden(true)
            
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 10)
                
                // TextEditor
                TextEditor(text: $text)
                    .focused($isFocused)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .scrollContentBackground(.hidden)
                    .padding(15)
//                    .frame(minHeight: 80, maxHeight: 150, alignment: .topLeading)
                    .accessibilityLabel("Extra context")
                // Скрывать клавиатуру по Return:
                    .onChange(of: text) { _, newValue in
                        // Если последний введённый символ — перевод строки, убираем его и снимаем фокус
                        if newValue.last == "\n" {
                            text = newValue.trimmingCharacters(in: .newlines)
                            isFocused = false
                        }
                    }
                
                // Placeholder
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Add any details to help generate a better reply…")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(15)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .onTapGesture { isFocused = true }
        }
    }
}


#Preview {
    
    @Previewable @State var text = "asdasd"
    @FocusState var isFocused
    
    ContextInputCard(text: $text, isFocused: $isFocused)
}

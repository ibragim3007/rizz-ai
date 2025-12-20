//
//  SecondScreenContent.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI


struct SecondScreenContent: View {
    @State private var isLevitation = false

    var body: some View {
        ZStack {
            Image("girl-4")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320)
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                .accessibilityHidden(true)
                .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
                .overlay {
                    Image("message-purple")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .shadow(color: AppTheme.primary.opacity(0.5), radius: 15, x: 0, y: 12)
                        .shadow(color: Color.black.opacity(0.4), radius: 15)
                        .accessibilityHidden(true)
                        // Базовое позиционирование
                        .offset(x: 110, y: -120 + (isLevitation ? -8 : 8))
                        // Плавная "левитация" вверх-вниз
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isLevitation)
                        .onAppear { isLevitation = true }
                }
        }
    }
}

#Preview {
    SecondScreenContent()
}

//
//  ShortcutExplainer.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/3/25.
//

import SwiftUI

struct ShortcutExplainer: View {
    
    // Внешнее действие при нажатии "Let's start"
    var onStart: () -> Void = {}
    
    var body: some View {
        ZStack {
            // Фирменный фон
            MeshedGradient()
            
            // Контент
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Text("Reply Like a Pro")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.top, 20)
                    
                    VStack(spacing: 8) {
                        Text("Generate clever AI responses for any chat or post.")
                        Text("They’re already copied — just paste and send.")
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    
                    // Центральная иллюстрация
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                            )
                            .shadow(color: AppTheme.glow.opacity(0.18), radius: 14, x: 0, y: 8)
                        
                        Image("shortcut-intro") // замените на нужный ассет при необходимости
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(12)
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 120) // запас под нижнюю кнопку
            }
            
            // Нижняя CTA-кнопка
            VStack {
                Spacer()
                PrimaryCTAButton(
                    title: "Let’s start",
                    height: 60,
                    font: .system(size: 20, weight: .semibold, design: .rounded),
                    fullWidth: true
                ) {
                    onStart()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ShortcutExplainer()
        .preferredColorScheme(.dark)
}

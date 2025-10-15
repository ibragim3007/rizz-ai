//
//  ToneButtonView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct ToneButtonView: View {
    
    @AppStorage("tone") private var currentTone: ToneTypes = .RIZZ
    
    // Явный порядок переключения
    private let orderedTones: [ToneTypes] = [.RIZZ, .ROMANTIC, .FLIRT, .NSFW]
    
    // Состояния для анимации
    @State private var isAnimatingTap = false
    @State private var shakeProgress: CGFloat = 0 // триггер для "тряски"
    
    // Tooltip
    @State private var showTooltip = false
    @State private var tooltipTask: Task<Void, Never>?
    
    var body: some View {
        Button(action: {
            // Легкая вибрация
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            
            // Смена тона
            cycleTone()
            
            // Показать тултип с выбранным режимом
            showToneTooltip()
            
            // Анимации: пружинящий скейл/поворот + "тряска"
            animateTap()
        }) {
            Text(getToneName(tone: currentTone))
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 55, height: 55)
                .contentShape(Circle())
                // Эффекты анимации
                .scaleEffect(isAnimatingTap ? 1.14 : 1.0)
                .rotationEffect(.degrees(isAnimatingTap ? 10 : 0))
                .animation(.spring(response: 0.28, dampingFraction: 0.6, blendDuration: 0.2), value: isAnimatingTap)
                // Легкая "тряска" по оси X
                .modifier(ShakeEffect(amount: 6, shakesPerUnit: 3, animatableData: shakeProgress))
                .shadow(color: .black.opacity(0.2), radius: 5)
        }
        .buttonStyle(.plain)
        .background(
            ZStack {
                // Базовый круг
                Circle()
                    .fill(AppTheme.primary.opacity(1))
                
                // Сияние при нажатии
                Circle()
                    .stroke(AppTheme.glow.opacity(isAnimatingTap ? 0.9 : 0), lineWidth: isAnimatingTap ? 8 : 0)
                    .blur(radius: isAnimatingTap ? 10 : 0)
                    .scaleEffect(isAnimatingTap ? 1.2 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isAnimatingTap)
            }
        )
        .clipShape(Circle())
        // Tooltip над кнопкой
        .overlay(alignment: .top) {
            if showTooltip {
                TooltipBubble(text: accessibilityToneName(for: currentTone))
                    .offset(x: 20, y: -40) // немного над кнопкой
                    .transition(
                        .asymmetric(
                            insertion: .offset(y: 6).combined(with: .opacity),
                            removal: .opacity
                        )
                    )
                    .animation(.easeOut(duration: 0.25), value: showTooltip)
                    .accessibilityHidden(true)
            }
        }
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 8, x: 0, y: 4)
        .accessibilityLabel("Change tone")
        .accessibilityValue(accessibilityToneName(for: currentTone))
        .accessibilityAddTraits(.isButton)
    }
    
    private func animateTap() {
        // Пружинящий "бум"
        withAnimation(.spring(response: 0.22, dampingFraction: 0.55, blendDuration: 0.15)) {
            isAnimatingTap = true
        }
        // Тряска
        withAnimation(.easeInOut(duration: 0.25)) {
            shakeProgress += 1
        }
        // Возврат к исходному состоянию
        Task {
            try? await Task.sleep(nanoseconds: 180_000_000) // ~0.18s
            await MainActor.run {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.7, blendDuration: 0.2)) {
                    isAnimatingTap = false
                }
            }
        }
    }
    
    private func showToneTooltip() {
        // Отменяем предыдущий таймер скрытия, если быстро тапают
//        tooltipTask?.cancel()
        
        withAnimation(.easeOut(duration: 0.20)) {
            showTooltip = true
        }
        
        tooltipTask = Task { @MainActor in
            // Держим подсказку немного видимой
            try? await Task.sleep(nanoseconds: 1_250_000_000) // ~1.15s
            withAnimation(.easeIn(duration: 0.20)) {
                showTooltip = false
            }
        }
    }
    
    private func cycleTone() {
        if let idx = orderedTones.firstIndex(of: currentTone) {
            let nextIndex = orderedTones.index(after: idx)
            currentTone = nextIndex < orderedTones.endIndex ? orderedTones[nextIndex] : orderedTones.first!
        } else {
            currentTone = orderedTones.first!
        }
    }
    
    func getToneName(tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ:
            return "😎"
        case .ROMANTIC:
            return "💕"
        case .FLIRT:
            return "🫦"
        case .NSFW:
            return "😈"
        }
    }
    
    private func accessibilityToneName(for tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ: return "Rizz"
        case .ROMANTIC: return "Romantic"
        case .FLIRT: return "Flirt"
        case .NSFW: return "NSFW"
        }
    }
}

// Эффект "тряски" — лёгкое колебание по оси X
private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// Лёгкий пузырь-подсказка
private struct TooltipBubble: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 70)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial.opacity(0.5), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.primary.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 6)
            .shadow(color: AppTheme.primary.opacity(0.25), radius: 12, x: 0, y: 0)
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        OnboardingBackground
        HStack(spacing: 16) {
            ToneButtonView()
            PrimaryCTAButton(title: "Hello world") { }
        }
        .padding()
    }
}

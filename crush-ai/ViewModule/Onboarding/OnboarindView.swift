//
//  OnboarindView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI


// MARK: - View

struct OnboardingView: View {
    
    @StateObject var viewModel = OnboardingViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // Анимационные состояния
    @State private var floatLeft: Bool = false
    @State private var floatRight: Bool = true
    @State private var sparklePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            background
            content
            sparklesOverlay
        }
//        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: viewModel.currentIndex)
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Background
    
    private var background: some View {
        ZStack {
            // Дополнительная “аура” по центру
            RadialGradient(
                gradient: Gradient(colors: [
                    AppTheme.primary.opacity(AppTheme.auraCenterOpacity),
                    .clear
                ]),
                center: .center,
                startRadius: 10,
                endRadius: 420
            )
            .blendMode(.plusLighter)
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            
            VStack(spacing: 5) {
                Text("Not Getting Enough")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
                
                Text("Replies?")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.primaryGradient)
                    .multilineTextAlignment(.center)
                    .shadow(color: AppTheme.primary.opacity(0.55), radius: 20, x: 0, y: 0)
                
                // Подзаголовок
                Text("Messages getting ignored? Let us craft standout replies no more being left on read!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
                    .padding(.top, 14)
                    .padding(.horizontal, 24)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 2)
            
            // Кнопка
            PrimaryCTAButton(title: "Get Started", isShimmering: true,fullWidth: true, action: { viewModel.next() })
                .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Sparkles Overlay
    
    var sparklesOverlay: some View {
        GeometryReader { geo in
            ZStack {
                sparkle(at: CGPoint(x: geo.size.width * 0.22, y: geo.size.height * 0.22), size: 10, delay: 0.0, phase: sparklePhase)
                sparkle(at: CGPoint(x: geo.size.width * 0.78, y: geo.size.height * 0.28), size: 12, delay: 0.3, phase: sparklePhase)
                sparkle(at: CGPoint(x: geo.size.width * 0.18, y: geo.size.height * 0.58), size: 8, delay: 0.6, phase: sparklePhase)
            }
            .allowsHitTesting(false)
        }
    }
    
}

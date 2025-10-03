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
            VStack(spacing: 0) {
//                header
                pager
                pageIndicator
                footerButton.padding(.horizontal, 24)
            }
            sparklesOverlay
        }
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
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Header (Skip + Page Indicator)
    
    private var header: some View {
        HStack {
            // Пустой плейсхолдер для центрирования индикатора
            Color.clear.frame(width: 60, height: 44)
            
            pageIndicator
            
            Button("Skip") {
                viewModel.skipToEnd()
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .frame(width: 60, height: 44, alignment: .trailing)
            .accessibilityLabel("Skip onboarding")
        }
        .padding(.top, 12)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.steps.indices, id: \.self) { index in
                let isActive = index == viewModel.currentIndex
                Capsule()
                    .fill(isActive ? AppTheme.primary : .white.opacity(0.25))
                    .frame(width: isActive ? 18 : 6, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.currentIndex)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 8)
        .accessibilityLabel("Page \(viewModel.currentIndex + 1) of \(viewModel.steps.count)")
    }
    
    // MARK: - Pager Content
    
    private var pager: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.steps.indices, id: \.self) { index in
                OnboardingStepView(kind: viewModel.steps[index].kind)
                    .tag(index) // Match selection type (Int)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer Button
    
    private var footerButton: some View {
        VStack(spacing: 16) {
            PrimaryCTAButton(
                title: buttonTitle,
                isShimmering: viewModel.currentIndex == 0,
                fullWidth: true,
                action: onPrimaryButtonTap
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    
    private var buttonTitle: LocalizedStringKey {
        if viewModel.steps.count <= 1 { return "Get Started" }
        return viewModel.isLast ? "Finish" : (viewModel.currentIndex == 0 ? "Get Started" : "Next")
    }
    
    private func onPrimaryButtonTap() {
        if viewModel.isLast {
            hasSeenOnboarding = true
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                viewModel.next()
            }
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

//
//  PaywallView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    
    // Mock: можно пробросить реальные обработчики изнаружи
    var onContinue: (() -> Void)? = nil
    var onRestore: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    
    @State private var selected: Plan = .annual
    @State private var currentPage: Int = 0
    
    @State var currentOffering: Offering?
    
    
    // Моковые цены/тексты (заменишь на реальные из RevenueCat/StoreKit)
    private let annualSubtitle = "Most Popular – Annual Plan\nJust $0.57 / week"
    private let weeklySubtitle = "$2.99 / week, then $9.99"
    
    // Локальные изображения для карусели (замени на свои ассеты/URL)
    private let carouselImages: [String] = [
        "couple-1", // добавь такие имена в Assets или поменяй
        "couple-2",
        "couple-3"
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    header
                    
                    carousel
                        .padding(.horizontal, 20)
                    
                    Text("No Commitment – Cancel Anytime")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 6)
                    
                    // Cards
                    VStack(spacing: 14) {
                        planCard(
                            plan: .annual,
                            titlePrefix: "🔥 ",
                            title: "Most Popular – Annual Plan",
                            subtitle: "Just $0.57 / week",
                            badge: "SAVE 98%"
                        )
                        planCard(
                            plan: .weekly,
                            titlePrefix: "",
                            title: "Weekly plan",
                            subtitle: weeklySubtitle,
                            badge: nil
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    
                    continueButton
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    footerLinks
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
                .padding(.top, 14)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 6) {
            Text("Less Typing. More Dates.")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .tracking(1.0)
                .foregroundStyle(.white)
            
            Text("Quick lines that actually get replies")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Carousel
    
    private var carousel: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentPage) {
                ForEach(Array(carouselImages.enumerated()), id: \.offset) { idx, name in
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                            )
                            .overlay {
                                // Если нет ассета — покажем плейсхолдер
                                Image(name)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .opacity(UIImage(named: name) == nil ? 0 : 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .frame(height: 300)
                            .overlay {
                                if UIImage(named: name) == nil {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                    }
                    .padding(.vertical, 2)
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 310)
            
            // Custom page control
            HStack(spacing: 8) {
                ForEach(0..<carouselImages.count, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentPage ? AppTheme.primary : .white.opacity(0.25))
                        .frame(width: idx == currentPage ? 10 : 8, height: idx == currentPage ? 10 : 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 4)
        }
    }
    
    // MARK: - Plan Card
    
    private func planCard(plan: Plan, titlePrefix: String, title: String, subtitle: String, badge: String?) -> some View {
        let isSelected = selected == plan
        
        return Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                selected = plan
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(isSelected ? 0.10 : 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                isSelected
                                ? LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                : AppTheme.borderPrimaryGradient,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: AppTheme.glow.opacity(isSelected ? 0.35 : 0.0), radius: 16, x: 0, y: 8)
                
                if let badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.red)
                        .clipShape(Capsule())
                        .offset(x: -14, y: -12)
                }
                
                HStack(alignment: .center, spacing: 14) {
                    // Radio
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 36, height: 36)
                        if isSelected {
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 3)
                                .frame(width: 26, height: 26)
                        }
                    }
                    .padding(.leading, 12)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            if !titlePrefix.isEmpty {
                                Text(titlePrefix)
                            }
                            Text(title)
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 8)
                }
                .padding(.vertical, 18)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title)"))
        .accessibilityHint(Text(isSelected ? "Selected" : "Tap to select"))
    }
    
    // MARK: - Continue
    
    private var continueButton: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            onContinue?()
        } label: {
            Text("Continue")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.glow.opacity(0.45), radius: 18, x: 0, y: 10)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Continue")
    }
    
    // MARK: - Footer
    
    private var footerLinks: some View {
        HStack(spacing: 28) {
            Link("Terms", destination: URL(string: "https://example.com/terms")!)
            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
            Button("Restore") {
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                onRestore?()
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .foregroundStyle(.white.opacity(0.85))
        .padding(.vertical, 6)
    }
}

// MARK: - Model

private enum Plan: String, CaseIterable {
    case annual
    case weekly
}

// MARK: - Preview

#Preview("Paywall – Dark") {
    PaywallView(
        onContinue: { print("Continue tapped") },
        onRestore: { print("Restore tapped") },
        onDismiss: { print("Dismiss tapped") }
    )
    .preferredColorScheme(.dark)
    .previewLayout(.device)
}

#Preview("Paywall – Small") {
    PaywallView()
        .previewDisplayName("iPhone SE size")
        .previewDevice("iPhone SE (3rd generation)")
        .preferredColorScheme(.dark)
}

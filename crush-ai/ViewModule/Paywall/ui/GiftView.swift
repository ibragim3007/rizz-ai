//
//  GiftView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/20/25.
//

import SwiftUI
import RevenueCat

struct GiftView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    // Можно принять месячный пакет извне (приоритетнее всего)
    var injectedMonthlyPackage: Package? = nil
    
    @State private var currentOffering: Offering?
    @State private var isProcessing: Bool = false
    @State private var alertMessage: String?
    
    // Выбор тарифа для PlanCard — явно используем Plan
    @State private var selected: Plan = .monthly
    
    // Анимации подарка
    @State private var pulse: Bool = false
    @State private var bounce: Bool = false
    @State private var spin: Bool = false
    
    // Анимация кнопки "Continue"
    @State private var buttonBounce: Bool = false
    
    var body: some View {
        ZStack {
            MeshedGradient().opacity(0.7)
            
            VStack(spacing: 20) {
                header
                
                Spacer()
                
                animatedGift
                    .padding(.horizontal, 24)
                
                Text("Get Unlimited Replies")
                    .multilineTextAlignment(.center)
                    .fontWeight(.heavy)
                    .foregroundStyle(AppTheme.primaryGradient)
                    .font(.system(size: 40))
                    .shadow(color: AppTheme.primary.opacity(0.5), radius: 20)
                
                Spacer()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("No Commitment – Cancel Anytime")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                    
                    PlanCard(
                        selected: $selected,
                        plan: .monthly,
                        titlePrefix: "⏳ ",
                        title: "Monthly Plan",
                        subtitle: dynamicSubtitle(for: .monthly, package: { plan in package(for: plan) }),
                        badge: "LIMIT OFFER"
                    ).frame(maxHeight: 100)
                        .padding(.horizontal)
                    
                    purchaseButton
                        .padding(.horizontal, 20)
                        .disabled(isProcessing)
                        .opacity(isProcessing ? 0.85 : 1.0)
                }
                .padding(.bottom, 22)
            }
            .padding(.top, 8)
        }
        .onAppear {
            // Если пакет заранее не передали — подгрузим Offering, чтобы найти месячный
            if injectedMonthlyPackage == nil {
                Purchases.shared.getOfferings { offerings, error in
                    if let offer = offerings?.current, error == nil {
                        currentOffering = offer
                    }
                }
            }
            // Запускаем анимации
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.spring(response: 0.9, dampingFraction: 0.65).repeatForever(autoreverses: true)) { bounce = true }
            withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) { spin = true }
            // Запускаем лёгкую "прыгающую" анимацию кнопки
            startButtonBounce()
        }
        .onChange(of: isProcessing) { newValue in
            // Пока идёт покупка — успокаиваем кнопку
            if newValue {
                withAnimation(.spring(response: 0.35, dampingFraction: 1.0)) {
                    buttonBounce = false
                }
            } else {
                // Возобновляем мягкую анимацию после завершения
                startButtonBounce()
            }
        }
        .alert("Oops", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            CloseButton {
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                dismiss()
            }
            Spacer()
            
            VStack (alignment: .center, spacing: 5) {
                Text("One time offer")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(1.0)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("You will never see this again")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
            }
            Spacer()
            // Плейсхолдер под симметрию
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
    
    // MARK: - Animated Gift
    
    private var animatedGift: some View {
        ZStack {
            // Мягкое свечение
            Circle()
                .fill(AppTheme.primary.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: pulse ? 22 : 10)
                .scaleEffect(pulse ? 1.05 : 0.98)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
            
            // Контур с градиентом
            Circle()
                .stroke(AppTheme.primaryGradient, lineWidth: 3)
                .frame(width: 240, height: 240)
                .shadow(color: AppTheme.glow.opacity(0.35), radius: 16, x: 0, y: 10)
                .rotationEffect(.degrees(spin ? 360 : 0))
            
            // Сам подарок
            Image(systemName: "gift.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(AppTheme.primaryLight, .white)
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .scaleEffect(bounce ? 1.01 : 0.99)
                .shadow(color: AppTheme.glow.opacity(0.7), radius: 24, x: 0, y: 8)
                .overlay {
                    // Блики/частицы (простые точки)
                    ParticlesView(color: AppTheme.primary, count: 18)
                        .frame(width: 260, height: 260)
                        .allowsHitTesting(false)
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Purchase
    
    private var purchaseButton: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            startMonthlyPurchase()
        } label: {
            ZStack {
                Text(isProcessing ? "Processing..." : "Claim Limited Offer")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(isProcessing ? 0 : 1)
                
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.primaryGradient)
                    .shadow(color: AppTheme.glow.opacity(0.45), radius: 18, x: 0, y: 10)
            )
            // Небольшая "прыгающая" анимация
            .scaleEffect(buttonBounce ? 1.02 : 0.98)
            .offset(y: buttonBounce ? -2 : 2)
            .animation(
                .spring(response: 0.8, dampingFraction: 0.9)
                .repeatForever(autoreverses: true),
                value: buttonBounce
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isProcessing ? "Processing" : "Claim Limited Offer")
    }
    
    private func startMonthlyPurchase() {
        guard !isProcessing else { return }
        guard let pkg = monthlyPackage() else {
            alertMessage = "No monthly product available. Please try again later."
            return
        }
        isProcessing = true
        
        Task {
            do {
                let result = try await Purchases.shared.purchase(package: pkg)
                isProcessing = false
                // Обновляем состояние подписки в модели (даже если пользователь не закрыл paywall)
                refreshSubscriptionState(from: result.customerInfo)
                
                // Можно закрывать экран после успеха, если не отменено пользователем
                if !result.userCancelled {
                    dismiss()
                }
            } catch {
                isProcessing = false
                let nsError = error as NSError
                if nsError.code == ErrorCode.purchaseCancelledError.rawValue {
                    // тихая отмена
                } else {
                    alertMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - RevenueCat helpers
    
    // Пакет для любого плана (для переиспользования в dynamicSubtitle)
    private func package(for plan: Plan) -> Package? {
        switch plan {
        case .monthly:
            return monthlyPackage()
        case .annual:
            guard let offering = currentOffering else { return nil }
            return offering.availablePackages.first { $0.packageType == .annual }
        case .weekly:
            guard let offering = currentOffering else { return nil }
            return offering.availablePackages.first { $0.packageType == .weekly }
        }
    }
    
    private func monthlyPackage() -> Package? {
        // Приоритет: переданный извне пакет
        if let injectedMonthlyPackage { return injectedMonthlyPackage }
        // Иначе ищем в текущем офферинге
        guard let offering = currentOffering else { return nil }
        return offering.availablePackages.first { $0.packageType == .monthly }
    }
    
    // MARK: - Button bounce control
    
    private func startButtonBounce() {
        // Не запускаем бесконечную анимацию, если сейчас идёт процессинг
        guard !isProcessing else { return }
        withAnimation(
            .spring(response: 0.8, dampingFraction: 0.9)
            .repeatForever(autoreverses: true)
        ) {
            buttonBounce = true
        }
    }
    
    // MARK: - Paywall state refresh (mirrors PaywallView behavior)
    
    private func refreshSubscriptionState(from customerInfo: CustomerInfo?) {
        let isActive = customerInfo?.entitlements.all["Full Access"]?.isActive == true
        paywallViewModel.isSubscriptionActive = isActive
        // Обновим appUserID на случай его изменения SDK
        paywallViewModel.appUserID = Purchases.shared.appUserID
    }
}

// MARK: - Simple particles

private struct ParticlesView: View {
    let color: Color
    let count: Int
    
    @State private var randoms: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(randoms) { p in
                Circle()
                    .fill(color.opacity(p.opacity))
                    .frame(width: p.size, height: p.size)
                    .offset(x: p.x, y: p.y)
                    .animation(.easeInOut(duration: p.duration).repeatForever(autoreverses: true), value: p.phase)
            }
        }
        .onAppear {
            var tmp: [Particle] = []
            for i in 0..<count {
                tmp.append(.random(id: i))
            }
            randoms = tmp
            // триггер фазы
            for i in 0..<randoms.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                    randoms[i].phase.toggle()
                }
            }
        }
    }
    
    struct Particle: Identifiable {
        let id: Int
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var duration: Double
        var phase: Bool = false
        
        static func random(id: Int) -> Particle {
            Particle(
                id: id,
                x: CGFloat.random(in: -110...110),
                y: CGFloat.random(in: -110...110),
                size: CGFloat.random(in: 3...7),
                opacity: Double.random(in: 0.2...0.6),
                duration: Double.random(in: 1.2...2.6)
            )
        }
    }
}

#Preview {
    GiftView()
        .environmentObject(PaywallViewModel(isPreview: false))
}

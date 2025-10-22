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
    // Новый колбэк: отдаём наружу месячный пакет при закрытии
    var onDismissWithMonthly: ((Package?) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    @State private var selected: Plan = .annual
    @State private var currentPage: Int = 0
    
    @State var currentOffering: Offering?
    
    // Purchasing state
    @State private var isProcessing: Bool = false
    @State private var alertMessage: String?
    
    // Моковые цены/тексты (заменишь на реальные из RevenueCat/StoreKit)
    private let annualSubtitle = "Most Popular – Annual Plan\nJust $0.57 / week"
    private let weeklySubtitle = "$2.99 / week, then $9.99"
    
    // Локальные изображения для карусели (замени на свои ассеты/URL)
    private let carouselImages: [String] = [
        "couple-2", // добавь такие имена в Assets или поменяй
        "couple-1",
        "couple-3"
    ]
    
    var body: some View {
        ZStack {
            MeshedGradient().opacity(0.7)
            
            ScrollView {
                VStack(spacing: 18) {
                    
                    carousel
                        .padding(.horizontal, 20)
                        .overlay (alignment: .topLeading) {
                            CloseButton {
#if canImport(UIKit)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                                // Пробрасываем месячный пакет наружу при закрытии
                                onDismissWithMonthly?(monthlyPackage())
                                onDismiss?()
                                dismiss()
                            }
                            .offset(x: 30)
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                        }
                    
                    header
                        .padding(.bottom, 10)
                
                    
                    // Cards
                    VStack(spacing: 14) {
                        PlanCard(
                            selected: $selected,
                            plan: .annual,
                            titlePrefix: "🔥 ",
                            title: "Most Popular – Annual Plan",
                            subtitle: dynamicSubtitle(for: .annual, package: { plan in package(for: plan) }),
                            badge: "SAVE 98%",
                        )
                        PlanCard(
                            selected: $selected,
                            plan: .weekly,
                            titlePrefix: "",
                            title: "Weekly plan",
                            subtitle: dynamicSubtitle(for: .weekly, package: { plan in package(for: plan) }),
                            badge: nil
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    
                    VStack {
                        Text("No Commitment – Cancel Anytime")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                        
                        continueButton
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .disabled(isProcessing)
                            .opacity(isProcessing ? 0.8 : 1.0)
                        
                        footerLinks
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.top, 14)
            }
        }
        .preferredColorScheme(.dark)
        // Кнопка закрытия (крестик)
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
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
        VStack(spacing: 10) {
            HStack (alignment: .firstTextBaseline) {
                VStack (alignment: .center, spacing: 5) {
                    Text("Get unlimited replies")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .tracking(1.0)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("Proven to get more dates")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
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
    
    // MARK: - Continue (Purchase)
    
    private var continueButton: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            startPurchase()
        } label: {
            ZStack {
                Text(isProcessing ? "Processing..." : "Continue")
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isProcessing ? "Processing" : "Continue")
    }
    
    private func startPurchase() {
        guard !isProcessing else { return }
        guard let pkg = package(for: selected) else {
            alertMessage = "No product available for the selected plan. Please try again later."
            return
        }
        isProcessing = true
        
        Task {
            do {
                let result = try await Purchases.shared.purchase(package: pkg)
                
                // Обновляем состояние подписки из полученного CustomerInfo
                refreshSubscriptionState(from: result.customerInfo)
                
                isProcessing = false
                onContinue?() // Notify caller about success
                // Пробросим месячный пакет при закрытии
                onDismissWithMonthly?(monthlyPackage())
                onDismiss?()  // Optionally dismiss paywall after success
                dismiss()
            } catch {
                isProcessing = false
                // User cancellations are thrown as ErrorCode.purchaseCancelledError by the SDK.
                // Suppress alert for cancellations.
                let nsError = error as NSError
                if nsError.code == ErrorCode.purchaseCancelledError.rawValue {
                    // Silent cancellation
                } else {
                    alertMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerLinks: some View {
        HStack(spacing: 28) {
            Link("Terms", destination: URL(string: termsURLString)!)
            Link("Privacy", destination: URL(string: eulaPolicy)!)
            Button("Restore") {
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                restorePurchases()
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .foregroundStyle(.white.opacity(0.85))
        .padding(.vertical, 6)
    }
    
    private func restorePurchases() {
        guard !isProcessing else { return }
        isProcessing = true
        Task {
            do {
                let info = try await Purchases.shared.restorePurchases()
                // Обновляем состояние подписки после восстановления
                refreshSubscriptionState(from: info)
                
                isProcessing = false
                onRestore?()
                // Пробросим месячный пакет при закрытии
                onDismissWithMonthly?(monthlyPackage())
                onDismiss?()
                dismiss()
            } catch {
                isProcessing = false
                alertMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Subscription state helper
    
    private func refreshSubscriptionState(from customerInfo: CustomerInfo?) {
        // Используем ваш entitlement "Full Access"
        let isActive = customerInfo?.entitlements.all["Full Access"]?.isActive == true
        paywallViewModel.isSubscriptionActive = isActive
    }
}


// MARK: - RevenueCat helpers

private extension PaywallView {
    func package(for plan: Plan) -> Package? {
        guard let offering = currentOffering else { return nil }
        switch plan {
        case .annual:
            return offering.annual
        case .weekly:
            return offering.weekly
        case .monthly:
            return offering.monthly
        }
    }
    
    // Новый helper: месячный пакет из currentOffering
    func monthlyPackage() -> Package? {
        guard let offering = currentOffering else { return nil }
        print(offering.availablePackages.first { $0.packageType == .monthly })
        return offering.availablePackages.first { $0.packageType == .monthly }
    }
    
    
    // MARK: Price formatting helpers
    
    
    // Localized currency per week for periods longer than a week.
    // Uses calendar-based duration to derive weeks in the period to avoid rough constants.
    
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


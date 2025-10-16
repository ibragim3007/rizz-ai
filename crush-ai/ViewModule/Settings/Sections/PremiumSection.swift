//
//  PremiumSection.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI

struct PremiumSection: View {
    
    @Binding var showPaywall: Bool
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    var body: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            showPaywall = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: AppTheme.glow.opacity(0.35), radius: 10, x: 0, y: 6)
                    
                    Image(systemName: paywallViewModel.isSubscriptionActive ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        paywallViewModel.isSubscriptionActive
                        ? NSLocalizedString("Premium Active", comment: "Active subscription title")
                        : NSLocalizedString("Unlock Premium", comment: "Subscribe button title")
                    )
                    .font(.headline)
                    
                    Text(
                        paywallViewModel.isSubscriptionActive
                        ? NSLocalizedString("Thanks for supporting us!", comment: "Active subscription subtitle")
                        : NSLocalizedString("Unlimited lines, best tones and more", comment: "Subscribe button subtitle")
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                }
                
                Spacer()
                
                if !paywallViewModel.isSubscriptionActive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .disabled(paywallViewModel.isSubscriptionActive)
        .accessibilityLabel(
            paywallViewModel.isSubscriptionActive
            ? NSLocalizedString("Premium Active", comment: "Active subscription title")
            : NSLocalizedString("Unlock Premium", comment: "Subscribe button title")
        )
        .accessibilityHint(
            paywallViewModel.isSubscriptionActive
            ? NSLocalizedString("Your subscription is active", comment: "Active subscription hint")
            : NSLocalizedString("Opens the subscription screen", comment: "Subscribe button hint")
        )
    }
}

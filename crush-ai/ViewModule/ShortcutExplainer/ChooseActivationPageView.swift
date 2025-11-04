// ui/ChooseActivationPageView.swift
import SwiftUI

struct ChooseActivationPageView: View {
    var onSelectActionButton: () -> Void = {}
    var onSelectDoubleTap: () -> Void = {}
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Text("Choose Activation")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                
                VStack(spacing: 10) {
                    Text("Pick how you want to trigger the shortcut.")
                    Text("You can change this later in Settings.")
                }
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                
                VStack(spacing: 14) {
                    activationCard(
                        title: "Action Button",
                        subtitle: "For iPhone 15 Pro and newer",
                        systemImage: "actionbutton.programmable"
                    ) {
                        onSelectActionButton()
                    }
                    
                    activationCard(
                        title: "Double Tap",
                        subtitle: "Works on any iPhone",
                        systemImage: "hand.tap"
                    ) {
                        onSelectDoubleTap()
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
            .padding(.bottom, 120)
        }
    }
    
    @ViewBuilder
    private func activationCard(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 52, height: 52)
                        .shadow(color: AppTheme.glow.opacity(0.25), radius: 10, x: 0, y: 6)
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ChooseActivationPageView().preferredColorScheme(.dark)
}

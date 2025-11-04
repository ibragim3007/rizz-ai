// ui/InstallShortcutPageView.swift
import SwiftUI

struct InstallShortcutPageView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                Text("Install Shortcut")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                
                Spacer()
                
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
                    
                    Image("shortcut-install")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .frame(maxHeight: 450)
                        .padding(12)
                        .accessibilityHidden(true)
                        .overlay {
                            DownArrowHint()
                                .padding(.bottom, 2)
                                .accessibilityHidden(true)
                                .offset(y: 100)
                        }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.bottom, 140)
        }
    }
}

// A subtle animated down arrow hint (scoped to this page)
private struct DownArrowHint: View {
    @State private var animate = false
    
    var body: some View {
        Image(systemName: "arrow.down")
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(10)
            .background(
                Circle()
                    .fill(AppTheme.primary.opacity(0.60))
                    .overlay(
                        Circle().stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                    )
            )
            .shadow(color: AppTheme.glow.opacity(0.35), radius: 12, x: 0, y: 6)
            .offset(y: animate ? 0 : -6)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
    }
}

#Preview {
    InstallShortcutPageView().preferredColorScheme(.dark)
}

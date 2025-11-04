//
//  ShortcutExplainer.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/3/25.
//

import SwiftUI

struct ShortcutExplainer: View {
    
    @Environment(\.openURL) private var openURL
    
    // Insert the real iCloud link to your “Get Reply” shortcut
    private let getReplyShortcutURLString: String = "https://www.icloud.com/shortcuts/800fa932c78040bda5aeacb25d8f0a39"
    
    private func openGetReplyShortcut() {
        guard let icloudURL = URL(string: getReplyShortcutURLString) else { return }
        openURL(icloudURL)
    }
    
    // External action for finishing (used on "Continue" on the second screen)
    var onStart: () -> Void = {}
    
    @State private var pageSelection: Int = 0
    
    var body: some View {
        ZStack {
            // Branded background
            MeshedGradient()
            
            // Pager with two screens
            TabView(selection: $pageSelection) {
                // Page 0: Explainer
                explainerContent
                    .tag(0)
                
                // Page 1: Install Shortcut
                installShortcutContent
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom CTA(s) overlay
            VStack {
                Spacer()
                
                Group {
                    if pageSelection == 0 {
                        PrimaryCTAButton(
                            title: "Let’s start",
                            height: 60,
                            font: .system(size: 20, weight: .semibold, design: .rounded),
                            fullWidth: true
                        ) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                pageSelection = 1
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            PrimaryCTAButton(
                                title: "Add Shortcut",
                                height: 56,
                                font: .system(size: 18, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
                                openGetReplyShortcut()
                                // TODO: Wire to your Shortcut URL or action
                                // e.g., UIApplication.shared.open(URL(string: "shortcuts://...")!)
                            }
                            
                            SecondaryCTAButton(
                                title: "Continue",
                                height: 52,
                                font: .system(size: 17, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
                                onStart()
                            }
                        }
                    }
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

// MARK: - Subviews

private extension ShortcutExplainer {
    var explainerContent: some View {
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
                
                // Central illustration
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
                    
                    Image("shortcut-intro") // replace with your asset if needed
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
            .padding(.bottom, 120) // extra space for bottom button
        }
    }
    
    var installShortcutContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                Text("Install Shortcut")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                
                Spacer()
                
                // Illustration with screenshot/instructions
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
                    
                    Image("shortcut-install") // add your install screenshot asset
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .frame(maxHeight: 450)
                        .padding(12)
                        .accessibilityHidden(true)
                        .overlay {
                            // Arrow hint above the illustration pointing down
                            DownArrowHint()
                                .padding(.bottom, 2)
                                .accessibilityHidden(true)
                                .offset(y: 100)
                                
                        }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.bottom, 140) // reserve for two bottom buttons
        }
    }
}

// A lightweight secondary-styled CTA to complement PrimaryCTAButton
private struct SecondaryCTAButton: View {
    let title: LocalizedStringKey
    let height: CGFloat
    let font: Font
    let fullWidth: Bool
    let action: () -> Void
    
    init(
        title: LocalizedStringKey,
        height: CGFloat = 52,
        font: Font = .system(size: 17, weight: .semibold, design: .rounded),
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.height = height
        self.font = font
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .frame(height: height)
                .contentShape(Rectangle())
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

// A subtle animated down arrow hint
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
    ShortcutExplainer()
        .preferredColorScheme(.dark)
}

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
    
    // External action for finishing (used to dismiss from parent if needed)
    var onStart: () -> Void = {}
    
    // Optional callbacks when user picks an activation method
    var onSelectActionButton: () -> Void = {}
    var onSelectDoubleTap: () -> Void = {}
    
    @State private var pageSelection: Int = 0
    
    var body: some View {
        ZStack {
            // Branded background
            MeshedGradient()
            
            // Pager with three screens
            TabView(selection: $pageSelection) {
                // Page 0: Explainer
                ExplainerPageView()
                    .tag(0)
                
                // Page 1: Install Shortcut
                InstallShortcutPageView()
                    .tag(1)
                
                // Page 2: Choose Activation
                ChooseActivationPageView(
                    onSelectActionButton: {
                        onSelectActionButton()
                        onStart()
                    },
                    onSelectDoubleTap: {
                        onSelectDoubleTap()
                        onStart()
                    }
                )
                .tag(2)
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
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                pageSelection = 1
                            }
                        }
                    } else if pageSelection == 1 {
                        VStack(spacing: 12) {
                            PrimaryCTAButton(
                                title: "Add Shortcut",
                                height: 56,
                                font: .system(size: 18, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
            #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
                                openGetReplyShortcut()
                            }
                            
                            SecondaryCTAButton(
                                title: "Continue",
                                height: 52,
                                font: .system(size: 17, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                    pageSelection = 2
                                }
                            }
                        }
                    } else {
                        // Page 2 has its own inline CTAs inside the content; keep bottom area for spacing/gradient
                        EmptyView()
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

#Preview {
    ShortcutExplainer()
}

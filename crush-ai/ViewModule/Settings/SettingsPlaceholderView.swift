//
//  Untitled.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI
import SwiftData

struct SettingsPlaceholderView: View {
    
    @AppStorage("replyLanguage") private var replyLanguage: String = "auto"
    @AppStorage("tone") private var currentTone: ToneTypes = .RIZZ
    @AppStorage("useEmojis") private var useEmojis: Bool = false

    @State private var showPaywall: Bool = false
    @Environment(\.openURL) private var openURL
    
    // Insert the real iCloud link to your “Get Reply” shortcut
    private let getReplyShortcutURLString: String = "https://www.icloud.com/shortcuts/800fa932c78040bda5aeacb25d8f0a39"

    var body: some View {
        ZStack {
            MeshedGradient().opacity(0.5)
            List {
                // Premium section with a subscribe button
                Section("Premium") {
                    PremiumSection(showPaywall: $showPaywall)
                }
                
                // Shortcuts section with a pre‑save button for "Get Reply"
                Section("Shortcuts") {
                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                        openGetReplyShortcut()
                    } label: {
                        HStack(spacing: 12) {
                            // Shortcuts‑style glyph
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .purple.opacity(0.18), radius: 6, x: 0, y: 3)
                                // SF Symbol to suggest adding a shortcut
                                Image(systemName: "app.badge.plus")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("Add “Get Reply” Shortcut", comment: "Add Get Reply shortcut button"))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text(NSLocalizedString("Opens the Shortcuts app to install it.", comment: "Subtitle explaining the shortcut action"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("Add Get Reply shortcut", comment: "Accessibility label for adding shortcut"))
                    .accessibilityHint(NSLocalizedString("Opens the Shortcuts app to install the shortcut.", comment: "Accessibility hint for adding shortcut"))
                }
                
                Section("Settings") {
                    
                    // Language
                    Picker(selection: $replyLanguage) {
                        ForEach(languageOptions) { option in
                            Text(option.title).tag(option.id)
                        }
                    } label: {
                        Text(NSLocalizedString("Response language", comment: "Response language"))
                    }
                    
                    // Tone
                    Picker(selection: $currentTone) {
                        ForEach(ToneTypes.allCases, id: \.self) { tone in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(toneTitle(for: tone))
                                    .font(.body)
                                Text(toneDescription(for: tone))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .tag(tone)
                        }
                    } label: {
                        Text(NSLocalizedString("Tone", comment: "Response tone"))
                    }
                    
                    // Emoji in responses
                    Toggle(isOn: $useEmojis) {
                        Text(NSLocalizedString("Use Emoji", comment: "Toggle to include emoji in responses"))
                    }
                }
                
                // Feedback section
                Section("Feedback") {
                    FeedbackSection()
                }
                
                // Legal section
                Section("Legal") {
                    LegalSection()
                }
                
                Section("Storage") {
                    StorageSection()
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView(
                    onContinue: {
                        // Handle successful purchase (optional)
                    },
                    onRestore: {
                        // Handle restore (optional)
                    },
                    onDismiss: {
                        showPaywall = false
                    }
                )
                .preferredColorScheme(.dark)
            }
        }
    }
    
    // MARK: - Shortcuts helpers
    
    private func openGetReplyShortcut() {
        guard let icloudURL = URL(string: getReplyShortcutURLString) else { return }
        // Try to open the direct iCloud link
        openURL(icloudURL)
        // As a fallback, build a shortcuts:// import link
        if let encoded = getReplyShortcutURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let importURL = URL(string: "shortcuts://import-shortcut?url=\(encoded)") {
            // Non‑blocking fallback: tries to open the Shortcuts app directly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                openURL(importURL)
            }
        }
    }
    
    // MARK: - Language / Tone helpers
    
    private struct LanguageOption: Identifiable, Hashable {
        let id: String          // BCP-47, or "auto"
        let title: String       // Human-readable name
    }
    
    // Auto + ~10 languages with flag emoji
    private var languageOptions: [LanguageOption] {
        [
            LanguageOption(id: "auto",    title: "🌐 " + NSLocalizedString("Automatic", comment: "Language - automatic")),
            LanguageOption(id: "en",      title: "🇺🇸 English"),
            LanguageOption(id: "es",      title: "🇪🇸 Español"),
            LanguageOption(id: "de",      title: "🇩🇪 Deutsch"),
            LanguageOption(id: "fr",      title: "🇫🇷 Français"),
            LanguageOption(id: "it",      title: "🇮🇹 Italiano"),
            LanguageOption(id: "pt",      title: "🇵🇹 Português"),
            LanguageOption(id: "ru",      title: "🇷🇺 Русский"),
            LanguageOption(id: "zh-Hans", title: "🇨🇳 中文（简体）"),
            LanguageOption(id: "ja",      title: "🇯🇵 日本語"),
            LanguageOption(id: "ko",      title: "🇰🇷 한국어")
        ]
    }
    
    private func toneTitle(for tone: ToneTypes) -> String {
        let toneEmoji: String = getToneName(tone: tone)
        switch tone {
        case .RIZZ:
            return toneEmoji + " " + NSLocalizedString("Rizz", comment: "Tone: Rizz")
        case .FLIRT:
            return toneEmoji + " " + NSLocalizedString("Flirty", comment: "Tone: Flirty")
        case .ROMANTIC:
            return toneEmoji + " " + NSLocalizedString("Romantic", comment: "Tone: Romantic")
        case .NSFW:
            return toneEmoji + " " + NSLocalizedString("NSFW", comment: "Tone: NSFW")
        }
    }
    
    private func toneDescription(for tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ:
            return NSLocalizedString("Confident, witty, and bold — charismatic one‑liners with swagger.", comment: "Description for RIZZ tone")
        case .FLIRT:
            return NSLocalizedString("Playful teasing and light compliments — fun, casual, and cheeky.", comment: "Description for FLIRT tone")
        case .ROMANTIC:
            return NSLocalizedString("Warm, sincere, and affectionate — sweet lines with deeper feelings.", comment: "Description for ROMANTIC tone")
        case .NSFW:
            return NSLocalizedString("Explicit and daring — adult‑oriented replies. Use with caution.", comment: "Description for NSFW tone")
        }
    }
}

#Preview {
    @Previewable @StateObject var paywallViewModel = PaywallViewModel()
    
    SettingsPlaceholderView().environmentObject(paywallViewModel)
}

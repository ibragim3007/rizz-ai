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
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshedGradient().opacity(0.5)
                List {
                    // Premium section with a subscribe button
                    Section("Premium") {
                        PremiumSection(showPaywall: $showPaywall)
                    }
                    
                    // Shortcuts section with a pre‑save button for "Get Reply"
                    Section("Shortcuts") {
                        ShortcutButton()
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
                    
                    Section("Account") {
                        NavigationLink(destination: StorageSettingsView()) {
                            Label {
                                Text("Storage")
                            } icon: {
                                Image(systemName: "externaldrive")
                            }
                        }
                        
                        DeleteAccountButton()
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
    }
    
    // MARK: - Language / Tone helpers
    
    private struct LanguageOption: Identifiable, Hashable {
        let id: String          // BCP-47, or "auto"
        let title: String       // Human-readable name
    }
    
    // Auto + European languages (incl. Scandinavian/Nordic)
    private var languageOptions: [LanguageOption] {
        [
            // Auto
            LanguageOption(id: "auto",    title: "🌐 " + NSLocalizedString("Automatic", comment: "Language - automatic")),
            
            // Big existing set
            LanguageOption(id: "en",      title: "🇺🇸 English"),
            LanguageOption(id: "es",      title: "🇪🇸 Español"),
            LanguageOption(id: "de",      title: "🇩🇪 Deutsch"),
            LanguageOption(id: "fr",      title: "🇫🇷 Français"),
            LanguageOption(id: "it",      title: "🇮🇹 Italiano"),
            LanguageOption(id: "pt",      title: "🇵🇹 Português"),
            LanguageOption(id: "ru",      title: "🇷🇺 Русский"),
            LanguageOption(id: "zh-Hans", title: "🇨🇳 中文（简体）"),
            LanguageOption(id: "ja",      title: "🇯🇵 日本語"),
            LanguageOption(id: "ko",      title: "🇰🇷 한국어"),
            
            // Scandinavian & Nordic
            LanguageOption(id: "sv",      title: "🇸🇪 Svenska"),
            LanguageOption(id: "da",      title: "🇩🇰 Dansk"),
            LanguageOption(id: "nb",      title: "🇳🇴 Norsk Bokmål"),
            LanguageOption(id: "nn",      title: "🇳🇴 Norsk Nynorsk"),
            LanguageOption(id: "is",      title: "🇮🇸 Íslenska"),
            LanguageOption(id: "fo",      title: "🇫🇴 Føroyskt"),
            LanguageOption(id: "fi",      title: "🇫🇮 Suomi"),
            
            // Western Europe
            LanguageOption(id: "nl",      title: "🇳🇱 Nederlands"),
            LanguageOption(id: "nl-BE",   title: "🇧🇪 Nederlands (België)"),
            LanguageOption(id: "ga",      title: "🇮🇪 Gaeilge"),
            LanguageOption(id: "gd",      title: "🏴 Scottish Gaelic"), // regional flag may not render everywhere
            LanguageOption(id: "cy",      title: "🏴 Welsh (Cymraeg)"), // regional flag may not render everywhere
            LanguageOption(id: "mt",      title: "🇲🇹 Malti"),
            LanguageOption(id: "lb",      title: "🇱🇺 Lëtzebuergesch"),
            
            // Southern Europe
            LanguageOption(id: "pt-PT",   title: "🇵🇹 Português (Portugal)"),
            LanguageOption(id: "pt-BR",   title: "🇧🇷 Português (Brasil)"),
            LanguageOption(id: "ca",      title: "🌍 Català"),
            LanguageOption(id: "eu",      title: "🌍 Euskara"),
            LanguageOption(id: "gl",      title: "🌍 Galego"),
            LanguageOption(id: "el",      title: "🇬🇷 Ελληνικά"),
            LanguageOption(id: "sq",      title: "🇦🇱 Shqip"),
            
            // Central Europe
            LanguageOption(id: "pl",      title: "🇵🇱 Polski"),
            LanguageOption(id: "cs",      title: "🇨🇿 Čeština"),
            LanguageOption(id: "sk",      title: "🇸🇰 Slovenčina"),
            LanguageOption(id: "hu",      title: "🇭🇺 Magyar"),
            LanguageOption(id: "sl",      title: "🇸🇮 Slovenščina"),
            LanguageOption(id: "hr",      title: "🇭🇷 Hrvatski"),
            LanguageOption(id: "bs",      title: "🇧🇦 Bosanski"),
            LanguageOption(id: "sr-Cyrl", title: "🇷🇸 Српски (Ћирилица)"),
            LanguageOption(id: "sr-Latn", title: "🇷🇸 Srpski (Latinica)"),
            LanguageOption(id: "ro",      title: "🇷🇴 Română"),
            LanguageOption(id: "bg",      title: "🇧🇬 Български"),
            LanguageOption(id: "mk",      title: "🇲🇰 Македонски"),
            
            // Eastern Europe / Caucasus
            LanguageOption(id: "uk",      title: "🇺🇦 Українська"),
            LanguageOption(id: "be",      title: "🇧🇾 Беларуская"),
            LanguageOption(id: "tr",      title: "🇹🇷 Türkçe"),
            LanguageOption(id: "hy",      title: "🇦🇲 Հայերեն"),
            LanguageOption(id: "ka",      title: "🇬🇪 ქართული"),
            LanguageOption(id: "az",      title: "🇦🇿 Azərbaycanca")
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

// MARK: - Storage screen wrapper
private struct StorageSettingsView: View {
    var body: some View {
        List {
            Section {
                StorageSection()
            } header: {
                Text("Storage")
            }
        }
        .navigationTitle("Storage")
        .scrollContentBackground(.hidden)
        .background {
            MeshedGradient().opacity(0.5)
        }
    }
}

#Preview {
    @Previewable @StateObject var paywallViewModel = PaywallViewModel()
    
    SettingsPlaceholderView().environmentObject(paywallViewModel)
}

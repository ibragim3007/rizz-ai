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
    @State private var showPaywall: Bool = false
    @EnvironmentObject private var paywallViewModel: PaywallViewModel

    var body: some View {
        ZStack {
            MeshedGradient().opacity(0.5)
            List {
                // Premium section with a beautiful subscribe button
                Section("Premium") {
                    PremiumSection(showPaywall: $showPaywall)
                }
                
                Section("Settings") {
                                    
                    // Язык
                    Picker(selection: $replyLanguage) {
                        ForEach(languageOptions) { option in
                            Text(option.title).tag(option.id)
                        }
                    } label: {
                        Text(NSLocalizedString("Response language", comment: "Response language"))
                    }
                    
                    // Тон
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
                        // Обработка успешной покупки (опционально)
                    },
                    onRestore: {
                        // Обработка восстановления (опционально)
                    },
                    onDismiss: {
                        showPaywall = false
                    }
                )
                .preferredColorScheme(.dark)
            }
        }
    }
    
    
    private struct LanguageOption: Identifiable, Hashable {
        let id: String          // BCP-47, либо "auto"
        let title: String       // Человекочитаемое имя
    }
    
    // Авто + ~10 языков с эмодзи флагов
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

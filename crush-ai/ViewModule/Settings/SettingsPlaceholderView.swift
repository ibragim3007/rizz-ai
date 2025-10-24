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
    
    // Вставьте реальную iCloud‑ссылку на ваш шорткат «Get Reply»
    private let getReplyShortcutURLString: String = "https://www.icloud.com/shortcuts/800fa932c78040bda5aeacb25d8f0a39"

    var body: some View {
        ZStack {
            MeshedGradient().opacity(0.5)
            List {
                // Premium section with a beautiful subscribe button
                Section("Premium") {
                    PremiumSection(showPaywall: $showPaywall)
                }
                
                // Shortcuts section with a pre-save button for "Get Reply"
                Section("Shortcuts") {
                    Button {
#if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                        openGetReplyShortcut()
                    } label: {
                        HStack {
                            Text(NSLocalizedString("Добавить шорткат “Get Reply”", comment: "Add Get Reply shortcut button"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("Добавить шорткат Get Reply", comment: "Accessibility label for adding shortcut"))
                    .accessibilityHint(NSLocalizedString("Откроет установку шортката в приложении «Команды»", comment: "Accessibility hint for adding shortcut"))
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
                    
                    // Эмодзи в ответах
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
    
    // MARK: - Shortcuts helpers
    
    private func openGetReplyShortcut() {
        guard let icloudURL = URL(string: getReplyShortcutURLString) else { return }
        // Пробуем открыть прямую iCloud‑ссылку
        openURL(icloudURL)
        // На случай, если нужна явная схема импорта — соберём shortcuts:// ссылку
        if let encoded = getReplyShortcutURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let importURL = URL(string: "shortcuts://import-shortcut?url=\(encoded)") {
            // Неблокирующий фоллбэк: попытается открыть приложение «Команды» напрямую
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                openURL(importURL)
            }
        }
    }
    
    // MARK: - Language / Tone helpers
    
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

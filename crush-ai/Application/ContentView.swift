//
//  ContentView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("replyLanguage") private var replyLanguage: String = "auto"
    @AppStorage("useEmojis") private var useEmojis: Bool = false
    
    // Единый экземпляр PaywallViewModel для всего дерева
    @StateObject private var paywallViewModel: PaywallViewModel

    // Позволяем инъекцию PaywallViewModel (например, из превью или App)
    init(paywallViewModel: PaywallViewModel? = nil) {
        _paywallViewModel = StateObject(wrappedValue: paywallViewModel ?? PaywallViewModel())
    }
    
    private var selectedLocale: Locale {
        if replyLanguage == "auto" {
            return .autoupdatingCurrent
        } else {
            return Locale(identifier: replyLanguage)
        }
    }
    
    var body: some View {
        ZStack {
            if hasSeenOnboarding {
                MainView()
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
        .environment(\.locale, selectedLocale)
        .environmentObject(paywallViewModel)
    }
}

#Preview {
    // Пропускаем онбординг в превью, чтобы сразу увидеть основной экран
    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    return ContentViewPreviewContainer()
}

// Отдельный контейнер только для превью, чтобы избежать неоднозначности типов
private struct ContentViewPreviewContainer: View {
    @StateObject var paywallViewModel = PaywallViewModel(isPreview: true)
    
    // Локальный контейнер SwiftData с вашей схемой
    private let container: ModelContainer = {
        let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    var body: some View {
        // Инъецируем paywallViewModel напрямую в ContentView
        ContentView(paywallViewModel: paywallViewModel)
            .modelContainer(container)
            // Дополнительно environmentObject не нужен, ContentView сам прокинет вниз свой экземпляр
    }
}

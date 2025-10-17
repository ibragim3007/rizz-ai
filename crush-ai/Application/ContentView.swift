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
    @StateObject private var paywallViewModel = PaywallViewModel()
    
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
    @Previewable @StateObject var paywallViewModel = PaywallViewModel(isPreview: true)
    
    let container: ModelContainer = {
        let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        
        return container
    }()
    
    ContentView()
        .modelContainer(container)
        .environmentObject(paywallViewModel)
}

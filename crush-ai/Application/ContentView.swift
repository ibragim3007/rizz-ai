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
    
    private var selectedLocale: Locale {
        if replyLanguage == "auto" {
            return .autoupdatingCurrent
        } else {
            return Locale(identifier: replyLanguage)
        }
    }
    
    var body: some View {
        Group {
            if (hasSeenOnboarding) {
                MainView().preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
        .environment(\.locale, selectedLocale)
    }
}

#Preview {
    @Previewable @StateObject var paywallViewModel = PaywallViewModel()
    
    let container: ModelContainer = {
        let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        
        return container
    }()
    
    ContentView()
        .modelContainer(container)
        .environmentObject(paywallViewModel)
}


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
    
    var body: some View {
        
        if (hasSeenOnboarding) {
            MainView()
        } else {
            OnboardingView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    
    let container: ModelContainer = {
        let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        
        return container
    }()
    
    ContentView()
        .modelContainer(container)
}

//
//  ContentView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/1/25.
//

import SwiftUI

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
    ContentView()
}

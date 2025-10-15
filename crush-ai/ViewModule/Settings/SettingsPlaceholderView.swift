//
//  Untitled.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI
import SwiftData

struct SettingsPlaceholderView: View {
    
    var body: some View {
        List {
            Section("Settings") {
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
            
            Section("Storage") {
                StorageSection()
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Settings")
    }
    
    
    
}



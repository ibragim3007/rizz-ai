//
//  Home.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct Home: View {
    @State private var showSettings = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    
    let dialogs: [DialogEntity] = []
    
    var body: some View {
        ZStack {
            OnboardingBackground.opacity(0.5)
            
            if dialogs.isEmpty {
                EmptyDialogsView()
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
                        
            ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dialogs, id: \.self) { dialog in
                            ScreenShotItem(imageURL: dialog.image?.localFileURL, title: dialog.title)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                
            }
            .scrollIndicators(.hidden)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .toolbar {
                ToolbarItem (placement: .topBarLeading) { Logo() }.sharedBackgroundVisibility(.hidden)
                ToolbarItem { SettingsButton(showSettings: showSettings) }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer(minLength: 0)
                    PrimaryCTAButton(
                        title: "Upload Screenshot",
                        height: 60,
                        font: .system(size: 20, weight: .semibold, design: .rounded),
                        fullWidth: true
                    ) {
                        print("upload screenshot button")
                    }
                    .offset(y: -30)
                    .padding(.horizontal, 10)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }
}



// Заглушка настроек
private struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Settings") {
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
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
}

// Пустое состояние диалогов
private struct EmptyDialogsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Пока пусто")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
            Text("Загрузите скриншот, чтобы начать новый диалог.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}


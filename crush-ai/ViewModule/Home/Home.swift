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
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground.opacity(0.5)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<30, id: \.self) { index in
                        GridTilePlaceholder(index: index)
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
                    .padding(.horizontal, 10)
                }.sharedBackgroundVisibility(.hidden)
            }
        }
    }
}

private struct GridTilePlaceholder: View {
    let index: Int
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.26), .white.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(alignment: .bottom) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(6)
                }
                .frame(width: size.width, height: size.height) // квадрат
        }
        .aspectRatio(0.6, contentMode: .fit)
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

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}

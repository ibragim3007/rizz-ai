//
//  MainView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct MainView: View {
    @State private var showSettings = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)

    var body: some View {
        ZStack {
            OnboardingBackground.opacity(0.5)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<30, id: \.self) { index in
                            GridTilePlaceholder(index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                }
        }
        // Кнопка поверх контента, внутри safe area
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                PrimaryCTAButton(title: "Upload Screenshot", isShimmering: false) {
                    // TODO: upload action
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .background(.thinMaterial.opacity(1)) // можно усилить если нужно стекло
        }
        .sheet(isPresented: $showSettings) {
            SettingsPlaceholderView()
                .preferredColorScheme(.dark)
        }
        .preferredColorScheme(.dark)
    }
}



// Плейсхолдер карточки в сетке
private struct GridTilePlaceholder: View {
    let index: Int

    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.primary.opacity(0.12))
                )
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
                .shadow(color: AppTheme.primary.opacity(0.22), radius: 10, x: 0, y: 6)
                .overlay(alignment: .bottomLeading) {
                    // Небольшая маркировка/номер (можно убрать)
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(6)
                }
                .frame(width: size.width, height: size.width) // квадрат
        }
        .aspectRatio(1, contentMode: .fit)
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

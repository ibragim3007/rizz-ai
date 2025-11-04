//
//  Untitled.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import SwiftUI

struct EmptyDialogsView: View {
    // Минимальный набор анимаций
    @State private var showHero = false
    @State private var showChips = false

    var body: some View {
        VStack(spacing: 20) {

            // Hero / Illustration block
            VStack (spacing: 15) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                        )
                    
                    ZStack(alignment: .bottomLeading) {
                        Image(.welcom)
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: .infinity)
                            .accessibilityHidden(true)
                
                        
                        // Черный градиент снизу под текстом
                        LinearGradient(
                            colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(maxHeight: 150)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start a new dialog")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            
                            Text("Drop a screenshot — we’ll do the rest.")
                                .font(.system(.subheadline, design: .rounded))
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                }
                .opacity(showHero ? 1 : 0)
                //            .offset(y: showHero ? 0 : 14)
                .animation(.snappy(duration: 0.6), value: showHero)
                
                // Компактные подсказки
                HStack(spacing: 10) {
                    Chip(icon: "sparkles", text: "Smart reply")
                    Chip(icon: "photo.on.rectangle.angled", text: "Use screenshots")
                    Spacer(minLength: 0)
                }
                .opacity(showChips ? 1 : 0)
                .offset(y: showChips ? 0 : 10)
                .animation(.snappy(duration: 0.5), value: showChips)
                
            }
            
            // Главное действие
            ShortcutButton()
                .opacity(showHero ? 1 : 0)
                .offset(y: showHero ? 0 : 10)
                .animation(.snappy(duration: 0.5).delay(0.05), value: showHero)

            // Короткий хинт
            Text("Add more screenshots anytime to improve context.")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
                .opacity(showChips ? 1 : 0)
                .offset(y: showChips ? 0 : 8)
                .animation(.snappy(duration: 0.45).delay(0.05), value: showChips)
        }
        .padding(.vertical, 28)
        .task {
            await animateIn()
        }
    }

    // MARK: - Simple animation

    private func animateIn() async {
        showHero = false
        showChips = false

        try? await Task.sleep(nanoseconds: 120_000_000)
        withAnimation(.snappy(duration: 0.6)) { showHero = true }

        try? await Task.sleep(nanoseconds: 120_000_000)
        withAnimation(.snappy(duration: 0.5)) { showChips = true }
    }
}

// MARK: - Chip

private struct Chip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .accessibilityHidden(true)

            Text(text)
                .font(.system(.subheadline, design: .rounded))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
        )
    }
}

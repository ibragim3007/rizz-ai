//
//  BeforeAfterContent.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/4/25.
//

import SwiftUI

struct BeforeAfterContent: View {
    @State private var showBefore = false
    @State private var showAfter = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    MessageBubble(
                        text: "idk, maybe later",
                        avatar: Image("girl-1")
                    )
                    .overlay {
                        CapsuleLabel("Before 🥱", tint: .white.opacity(0.6))
                            .offset(x: 100, y: -48)
                    }
                }.opacity(showBefore ? 1 : 0)
                    .offset(x: showBefore ? 0 : -280)
                    .animation(.spring(response: 0.75, dampingFraction: 0.95, blendDuration: 3.7), value: showBefore)
                
                // VS divider
                HStack(spacing: 12) {
                    DividerLine()
                    Text("VS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .padding(.horizontal, 4)
                        .foregroundStyle(AppTheme.primaryGradient)
                    DividerLine()
                }
                .padding(.vertical, 4)
                
                // AFTER
                VStack(alignment: .leading, spacing: 12) {
                    MessageBubble(
                        text: "That rooftop shot is epic, free for coffee this week?",
                        avatar: Image("girl-2")
                    )
                    .overlay {
                        CapsuleLabel("After 😍", tint: AppTheme.primary)
                            .offset(x: 100, y: -48)
                    }
                }                    .opacity(showAfter ? 1 : 0)
                    .offset(x: showAfter ? 0 : 280)
                    .animation(.spring(response: 0.75, dampingFraction: 0.95, blendDuration: 3.7), value: showAfter)
                
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .onAppear {
            Task {
                // Появление первого (слева)
                if !showBefore {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.85, blendDuration: 0.2)) {
                            showBefore = true
                        }
                    }
                }
                
                // Небольшая задержка и появление второго (справа)
                try? await Task.sleep(nanoseconds: 350_000_000)
                if !showAfter {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.85, blendDuration: 0.2)) {
                            showAfter = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Small reusable bits

private struct CapsuleLabel: View {
    let text: String
    let tint: Color
    init(_ text: String, tint: Color) {
        self.text = text
        self.tint = tint
    }
    var body: some View {
        if #available(iOS 26.0, *) {
            Text(text.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
            //            .background(
            //                Capsule(style: .continuous)
            //                    .fill(tint.opacity(0.25))
            //                    .background(.ultraThinMaterial)
            //                    .cornerRadius(20)
            //            )
                .glassEffect()
        } else {
            Text(text.uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial)
            //            .background(
            //                Capsule(style: .continuous)
            //                    .fill(tint.opacity(0.25))
            //                    .background(.ultraThinMaterial)
            //                    .cornerRadius(20)
            //            )
        }
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.10))
            .frame(height: 1)
            .cornerRadius(1)
    }
}

#Preview {
    BeforeAfterContent()
        .preferredColorScheme(.dark)
}

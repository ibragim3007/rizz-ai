//
//  BeforeAfterContent.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/4/25.
//

import SwiftUI

struct BeforeAfterContent: View {
    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                
                // Header
                VStack(spacing: 8) {
                    Text("Before → After")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("How a rough opener becomes real interest")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                
                // BEFORE
                VStack(alignment: .leading, spacing: 12) {
                    CapsuleLabel("Before", tint: .white.opacity(0.6))
                    MessageBubble(
                        text: "idk, maybe later",
                        avatar: Image("girl-1")
                    )
                }
                
                // VS divider
                HStack(spacing: 12) {
                    DividerLine()
                    Text("VS")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 4)
                    DividerLine()
                }
                .padding(.vertical, 4)
                
                // AFTER
                VStack(alignment: .leading, spacing: 12) {
                    CapsuleLabel("After", tint: AppTheme.primary)
                    MessageBubble(
                        text: "That rooftop shot is epic—free for coffee this week?",
                        avatar: Image("girl-2")
                    )
                }
                
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
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
        Text(text.uppercased())
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.25))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
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

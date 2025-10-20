//
//  CloseButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/20/25.
//


import SwiftUI

struct CloseButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

//
//  ShimmerMask.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import UIKit
import SwiftUI

struct ShimmerMask: View {
    @State private var move: CGFloat = -1.0
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .white.opacity(0.0),
                .white.opacity(0.35),
                .white.opacity(0.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.plusLighter)
        .mask(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black.opacity(0.0), .black, .black.opacity(0.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: move * 420)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                move = 1.0
            }
        }
    }
}

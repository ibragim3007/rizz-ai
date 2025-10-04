//
//  MessageBubbles.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct MessageBubbles: View {
    @State private var showFirst = false
    @State private var showSecond = false
    @State private var showThird = false
    
    var body: some View {
        VStack (spacing: 15) {
            if showFirst {
                HStack {
                    MessageBubble(text: "You + me = test this theory?", badgeCount: 4, avatar: Image("girl-1"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 100) // был Spacer(minLength: 100)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
            if showSecond {
                HStack {
                    MessageBubble(text: "I swipe for charm. Prove you have it", badgeCount: 12, avatar: Image("girl-2"))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, 120) // был Spacer(minLength: 120) слева
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
            if showThird {
                HStack {
                    MessageBubble(text: "Your move, heartbreaker!", badgeCount: 1, avatar: Image("girl-3"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 30) // был Spacer(minLength: 30)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .scenePadding(.horizontal)
        .onAppear {
            // Сброс и запуск последовательной анимации при каждом появлении
            showFirst = false
            showSecond = false
            showThird = false
            
            Task { await playSequence() }
        }
    }
    
    @MainActor
    private func playSequence() async {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2)) {
            showFirst = true
        }
        try? await Task.sleep(nanoseconds: 350_000_000)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2)) {
            showSecond = true
        }
        try? await Task.sleep(nanoseconds: 450_000_000)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 1, blendDuration: 0.5)) {
            showThird = true
        }
    }
}

#Preview {
    MessageBubbles()
        .padding(.horizontal, 20)
}

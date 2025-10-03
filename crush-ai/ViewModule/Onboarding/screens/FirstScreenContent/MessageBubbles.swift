//
//  MessageBubbles.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct MessageBubbles: View {
    var body: some View {
        VStack (spacing: 15) {
            HStack {
                MessageBubble(text: "hello!", badgeCount: 4, avatar: Image("girl-1"))
                Spacer(minLength: 100)
            }
            HStack {
                Spacer(minLength: 120)
                MessageBubble(text: "hello!", badgeCount: 12,avatar: Image("girl-2"))
            }
            HStack {
                MessageBubble(text: "hello!", badgeCount: 1, avatar: Image("girl-3"))
                Spacer(minLength: 30)
            }
        }.scenePadding(.horizontal)
    }
    
}

#Preview {
    MessageBubbles()
        .padding(.horizontal, 20)
}

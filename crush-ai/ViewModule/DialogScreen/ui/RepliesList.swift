//
//  RepliesList.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import SwiftUI
import SwiftData

struct RepliesList: View {
    var replies: [ReplyEntity]
    
    private var sortedReplies: [ReplyEntity] {
        replies.sorted { $0.createdAt < $1.createdAt }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if sortedReplies.isEmpty {
                // Плейсхолдер, когда ответов нет
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 16, weight: .semibold))
                    Text("No replies yet")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            } else {
                ForEach(sortedReplies, id: \.id) { reply in
                    ReplyView(content: reply.content, tone: reply.tone)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, 20)
        .animation(.snappy(duration: 0.28), value: replies.map(\.id))
    }
}

#Preview {
    let items: [ReplyEntity] = [
        ReplyEntity(id: UUID().uuidString, content: "before I decide if you're worth my attention, what's your best pickup line for a guy who already knows he's amazing?", createdAt: .now.addingTimeInterval(-120), tone: .RIZZ),
        ReplyEntity(id: UUID().uuidString, content: "If flirting were a sport, we'd both be in the finals.", createdAt: .now.addingTimeInterval(-60), tone: .FLIRT),
        ReplyEntity(id: UUID().uuidString, content: "As long as I’m breathing, I’ll keep choosing you.", createdAt: .now, tone: .ROMANTIC)
    ]
    
    return ScrollView {
        RepliesList(replies: items)
            .padding(.vertical)
    }
    .background(
        LinearGradient(
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
            startPoint: .top, endPoint: .bottom
        )
    )
    .preferredColorScheme(.dark)
}

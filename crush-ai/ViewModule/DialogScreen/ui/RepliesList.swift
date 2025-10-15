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
    
    @State private var animateGlow: Bool = false
    
    private var sortedReplies: [ReplyEntity] {
        replies.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if sortedReplies.isEmpty {
                placeholderReply
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
    
    
    private var placeholderReply: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 10)
                .overlay {
                    // Content
                    VStack(spacing: 10) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.primaryLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                Color.white.opacity(0.35)
                            )
                            .font(.system(size: 28, weight: .semibold))
                            .shadow(color: AppTheme.primary.opacity(0.25), radius: 10, x: 0, y: 6)
                        
                        Text("No replies yet")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Generate the first one and the magic will begin ✨")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 16)
                }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 12)
        .onAppear { animateGlow = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No replies yet")
        .accessibilityHint("Generate the first reply")
    }
    
}

#Preview {
    let items: [ReplyEntity] = [
        ReplyEntity(id: UUID().uuidString, content: "before I decide if you're worth my attention, what's your best pickup line for a guy who already knows he's amazing?", createdAt: .now.addingTimeInterval(-120), tone: .RIZZ),
        ReplyEntity(id: UUID().uuidString, content: "If flirting were a sport, we'd both be in the finals.", createdAt: .now.addingTimeInterval(-60), tone: .FLIRT),
        ReplyEntity(id: UUID().uuidString, content: "As long as I’m breathing, I’ll keep choosing you.", createdAt: .now, tone: .ROMANTIC)
    ]
    
    return ScrollView {
        RepliesList(replies: [])
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

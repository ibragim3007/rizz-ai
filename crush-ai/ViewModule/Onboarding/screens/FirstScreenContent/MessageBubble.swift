//
//  MessageBubble.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let badgeCount: Int?
    let avatar: Image?
    let avatarURL: URL?
    
    // Точки настройки
    private let cornerRadius: CGFloat = 50
    private let avatarSize: CGFloat = 64
    private let badgeSize: CGFloat = 36
    
    init(
        text: String,
        badgeCount: Int? = nil,            // например: 1 -> "+1"
        avatar: Image? = nil,              // локальная картинка
        avatarURL: URL? = nil              // или URL для загрузки
    ) {
        self.text = text
        self.badgeCount = badgeCount
        self.avatar = avatar
        self.avatarURL = avatarURL
    }
    
    var body: some View {
        HStack(spacing: 16) {
            avatarView
            Text(text)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            GlassBackground(cornerRadius: cornerRadius, tint: AppTheme.primaryDark)
        )
        .overlay(alignment: .topTrailing) {
            if let badgeCount {
                BadgeView(text: "+\(badgeCount)")
                    .frame(width: badgeSize, height: badgeSize)
                    .offset(x: 5, y: -5) // немного выступает за край
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel(Text("\(badgeCount) new messages"))
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: Avatar
    
    @ViewBuilder
    private var avatarView: some View {
        if let avatarURL {
            AsyncImage(url: avatarURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    placeholderAvatar
                case .empty:
                    ZStack {
                        Circle().fill(.white.opacity(0.08))
                        ProgressView()
                    }
                @unknown default:
                    placeholderAvatar
                }
            }
            .frame(width: avatarSize, height: avatarSize)
            .clipShape(Circle())
        } else if let avatar {
            avatar
                .resizable()
                .scaledToFit()
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
        } else {
            placeholderAvatar
        }
    }
    
    private var placeholderAvatar: some View {
        ZStack {
            Circle().fill(.white.opacity(0.08))
            Image(systemName: "person.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: avatarSize, height: avatarSize)
    }
}

// MARK: - Glass Background

private struct GlassBackground: View {
    let cornerRadius: CGFloat
    let tint: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        // Материал (blur) внутри формы
            .fill(.ultraThinMaterial)
        // Лёгкий тинт цветом темы
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.blue.opacity(0.75))
            )
    }
}

// MARK: - Badge (градиент из AppTheme)

private struct BadgeView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.glow.opacity(0.55), radius: 12, x: 0, y: 6)
            )
        
    }
}

// MARK: - Preview

#Preview("MessageBubble + AppTheme Glass") {
    ZStack {
        VStack(spacing: 24) {
            MessageBubble(
                text: "Hi, cutie!",
                badgeCount: 1,
                avatar: Image("girl-1"),
                avatarURL: nil
            )
            .padding(.horizontal, 20)
        }
    }
    .preferredColorScheme(.light)
}

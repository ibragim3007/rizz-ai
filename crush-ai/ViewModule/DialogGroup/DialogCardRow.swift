//
//  DialogCardRow.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct DialogCardRow: View {
    let dialog: DialogEntity
    
    private let corner: CGFloat = 32
    private let thumbSize: CGFloat = 88
    
    var body: some View {
        HStack(spacing: 16) {
            thumbnail
                .frame(width: thumbSize, height: thumbSize)
                .overlay(thumbnailShineOverlay)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(dialog.title.isEmpty ? "Untitled" : dialog.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.80)

                
//                if !dialog.displaySnippet.isEmpty {
//                    Text(dialog.displaySnippet)
//                        .font(.system(size: 14, weight: .medium, design: .rounded))
//                        .foregroundStyle(.white.opacity(0.75))
//                        .lineLimit(2)
//                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                    Text(dateSubtitle(for: dialog.updatedAt))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            
            Spacer(minLength: 8)
            
            chevron
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(glassBackground)
        .overlay(glossTopHighlight)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .padding(.horizontal, 20)
    }
    
    // MARK: Thumbnail
    
    @ViewBuilder
    private var thumbnail: some View {
        let radius: CGFloat = 20
        Group {
            if let image = dialog.image {
                PreviewImageView(imageEntity: image)
            } else if let cover = dialog.group?.cover {
                PreviewImageView(imageEntity: cover)
            } else {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.white.opacity(0.06))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
        )
    }
    
    private var thumbnailShineOverlay: some View {
        let radius: CGFloat = 20
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .stroke(
                LinearGradient(colors: [.white.opacity(0.35), .clear],
                               startPoint: .topLeading,
                               endPoint: .center),
                lineWidth: 1.0
            )
            .blendMode(.screen)
            .opacity(0.6)
    }
    
    // MARK: Chevron
    
    private var chevron: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle().fill(AppTheme.primary.opacity(0.18))
                )
                .overlay(
                    Circle().stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                )
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.20), radius: 10, x: 0, y: 6)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .accessibilityHidden(true)
    }
    
    // MARK: Background
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
        // Материал (blur)
            .fill(.ultraThinMaterial)
        // Тинт фирменным цветом
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(AppTheme.primaryDark.opacity(0.20))
            )
        // Глубина: glow + мягкие тени
            .shadow(color: AppTheme.primary.opacity(0.14), radius: 16, x: 0, y: 8)
    }
    
    private var glossTopHighlight: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.28),
                        .white.opacity(0.06),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.8
            )
            .blendMode(.screen)
            .opacity(0.7)
    }
    
    // MARK: Date formatting
    
    private func dateSubtitle(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("EEEE, HH:mm") // Friday, 16:53
        return df.string(from: date)
    }
}


#Preview {
    // Пример превью с фиктивными данными
    let cover = ImageEntity(id: "img1", localUrl: "girl-3", remoteUrl: "https://photosmint.com/wp-content/uploads/2025/03/Indian-Beauty-DP.jpeg")
    let d1 = DialogEntity(id: "1", userId: "u", title: "Home screen opener prep plsdfplsdfpls dlfsdlf psfd", createdAt: .now.addingTimeInterval(-3600), updatedAt: .now.addingTimeInterval(-3600))
    d1.image = cover
    
    return NavigationStack {
        VStack(spacing: 24) {
            DialogCardRow(dialog: d1)
                .preferredColorScheme(.dark)
                .padding(.top, 40)
        }
        .background(
            LinearGradient(colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}

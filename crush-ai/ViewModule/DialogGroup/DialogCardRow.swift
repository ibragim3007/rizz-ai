//
//  DialogCardRow.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct DialogCardRow: View {
    let dialog: DialogEntity
    
    private let corner: CGFloat = 28
    private let thumbSize: CGFloat = 84
    
    var body: some View {
        HStack(spacing: 16) {
            thumbnail
                .frame(width: thumbSize, height: thumbSize)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dialog.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                
                Text(dateSubtitle(for: dialog.updatedAt))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(glassBackground)
        .padding(.horizontal, 20)
    }
    
    // MARK: Thumbnail
    
    @ViewBuilder
    private var thumbnail: some View {
        if let image = dialog.image {
            PreviewImageView(imageEntity: image)
        } else if let cover = dialog.group?.cover {
            PreviewImageView(imageEntity: cover)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
        }
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(AppTheme.primaryDark.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
            )
//            .shadow(color: AppTheme.glow.opacity(0.12), radius: 14, x: 0, y: 8)
//            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
    }
    
    // MARK: Date formatting
    
    private func dateSubtitle(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("EEEE, HH:mm") // Friday, 16:53
        return df.string(from: date)
    }
}

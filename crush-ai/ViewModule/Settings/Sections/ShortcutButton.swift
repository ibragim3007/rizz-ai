//
//  ShortcutButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/24/25.
//

import SwiftUI

struct ShortcutButton: View {
    
    @Environment(\.openURL) private var openURL
    
    // Insert the real iCloud link to your “Get Reply” shortcut
    private let getReplyShortcutURLString: String = "https://www.icloud.com/shortcuts/800fa932c78040bda5aeacb25d8f0a39"

    
    var body: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            openGetReplyShortcut()
        } label: {
            HStack(spacing: 12) {
                // Shortcuts‑style glyph
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 36, height: 36)
                        .shadow(color: .purple.opacity(0.18), radius: 6, x: 0, y: 3)
                    // SF Symbol to suggest adding a shortcut
                    Image("apple-shortcut-icon")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("Add “Get Reply” Shortcut", comment: "Add Get Reply shortcut button"))
                        .font(.body)
                        .fontWeight(.semibold)
                    Text(NSLocalizedString("Opens the Shortcuts app to install it.", comment: "Subtitle explaining the shortcut action"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString("Add Get Reply shortcut", comment: "Accessibility label for adding shortcut"))
        .accessibilityHint(NSLocalizedString("Opens the Shortcuts app to install the shortcut.", comment: "Accessibility hint for adding shortcut"))
    }
    
    // MARK: - Shortcuts helpers
    
    private func openGetReplyShortcut() {
        print("BUtto pressed")
        guard let icloudURL = URL(string: getReplyShortcutURLString) else { return }
        // Try to open the direct iCloud link
        openURL(icloudURL)
        // As a fallback, build a shortcuts:// import link
//        if let encoded = getReplyShortcutURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//           let importURL = URL(string: "shortcuts://import-shortcut?url=\(encoded)") {
//            // Non‑blocking fallback: tries to open the Shortcuts app directly
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                openURL(importURL)
//            }
//        }
    }
    
}


#Preview {
    ShortcutButton()
}

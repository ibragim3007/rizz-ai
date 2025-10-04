//
//  PermissionNotification.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct PermissionNotification: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.primaryGradient)
                .shadow(color: AppTheme.primary.opacity(0.5), radius: 18, x: 0, y: 8)
                .accessibilityHidden(true)
            
            Text("Stay in the loop")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text("Enable notifications to get timely tips and replies that boost your conversations.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .padding(.top, 4)
        }
        .padding(.horizontal, 16)
    }
}

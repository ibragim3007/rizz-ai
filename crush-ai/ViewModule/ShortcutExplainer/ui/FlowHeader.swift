//
//  FlowHeader.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/4/25.
//

import SwiftUI

struct FlowHeader: View {
    
    var title: String
    var subtext: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.primaryGradient)
                .shadow(color: AppTheme.primary.opacity(0.45), radius: 16, x: 0, y: 6)
            
            Text(subtext)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

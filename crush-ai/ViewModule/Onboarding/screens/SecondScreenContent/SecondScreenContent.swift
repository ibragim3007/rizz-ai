//
//  SecondScreenContent.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI


struct SecondScreenContent: View {
    var body: some View {
        ZStack {
            Image("girl-4")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 320)
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                .accessibilityHidden(true)
                .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                .overlay {
                    Image("message-purple")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                        .accessibilityHidden(true)
                        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                        .shadow(color: Color.black.opacity(0.3), radius: 15)
                        .offset(x: 110, y: -120)
                }
        }
    }
}

#Preview {
    SecondScreenContent()
        .preferredColorScheme(.dark)
}

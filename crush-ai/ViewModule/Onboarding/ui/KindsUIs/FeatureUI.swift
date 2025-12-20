//
//  FeatureUI.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct FeatureUI: View {
    
    let title: String
    let highlightText: String
    let subtitle: String
    let imageName: String
    let illustration: AnyView?
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            if let illustration = illustration {
                illustration
            }
            
            Spacer()
            
            if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320)
                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 24, x: 0, y: 12)
                    .accessibilityHidden(true)
            }
            
            VStack(spacing: 15) {
                VStack {
                    Text(title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text(highlightText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryGradient)
                        .multilineTextAlignment(.center)
                }
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 330)
                    .padding(.top, 6)
            }
            .foregroundColor(AppTheme.fontMain)
            .padding(.horizontal, 16)
        }
    }
}

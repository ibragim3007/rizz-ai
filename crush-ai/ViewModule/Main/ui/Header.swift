//
//  Header.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//
import SwiftUI

struct Header: View {
    @State var showSettings = false
    
    var body: some View {
        HStack(alignment: .center) {
            Image("app-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle.init(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.primary.opacity(0.5), lineWidth: 1)
                }
            
            Spacer(minLength: 12)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle().strokeBorder(.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(color: AppTheme.glow.opacity(0.35), radius: 12, x: 0, y: 6)
                    )
            }
            .accessibilityLabel("Open settings")
        }
        
    }
}

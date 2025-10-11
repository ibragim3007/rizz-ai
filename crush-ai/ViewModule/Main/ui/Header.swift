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
                .clipShape(RoundedRectangle.init(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.primary.opacity(0.5), lineWidth: 1)
                }
            
            Spacer(minLength: 12)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(GlassButtonStyle())
            .accessibilityLabel("Open settings")
        }
        
    }
}

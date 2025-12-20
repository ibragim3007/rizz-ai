//
//  Header.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//
import SwiftUI
import SwiftData

struct Header: View {
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
            
            SettingsButton(destination: SettingsPlaceholderView())
        }
        
    }
}

struct SettingsButton<Destination: View>: View {
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.fontMain.opacity(0.8))
        }
        .simultaneousGesture(TapGesture().onEnded {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        })
        .accessibilityLabel("Open settings")
    }
}

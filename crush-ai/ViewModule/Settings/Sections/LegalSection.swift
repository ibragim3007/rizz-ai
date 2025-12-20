//
//  LegalSection.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/16/25.
//

import SwiftUI

struct LegalSection: View {
    
    @Environment(\.openURL) private var openURL
    
    
    var body: some View {
        Button {
        #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
            if let url = URL(string: termsURLString) {
                openURL(url)
            }
        } label: {
            HStack {
                Text(NSLocalizedString("Terms of Use", comment: "Legal: Terms of Use"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        
        Button {
        #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
            if let url = URL(string: privacyURLString) {
                openURL(url)
            }
        } label: {
            HStack {
                Text(NSLocalizedString("Privacy Policy", comment: "Legal: Privacy Policy"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
}

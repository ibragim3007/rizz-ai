//
//  StepsListCard.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/4/25.
//

import SwiftUI

struct StepsListCard: View {
    
    var steps: [String]
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(steps.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    let done = index < currentStep
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(done ? AppTheme.primary : .secondary, .clear)
                        .imageScale(.large)

                    Text(steps[index])
                        .font(.system(size: 16, weight: done ? .semibold : .regular, design: .rounded))
                        .foregroundStyle(done ? AppTheme.fontMain : AppTheme.fontMain.opacity(0.8))

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    currentStep = index + 1
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                }

                if index < steps.count - 1 {
                    Divider().overlay(AppTheme.fontMain.opacity(0.12)).padding(.leading, 28)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                .opacity(0.8)
        )
    }
}

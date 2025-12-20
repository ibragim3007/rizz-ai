//
//  ProgressSliderFlow.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/4/25.
//

import SwiftUI

struct ProgressSliderFlow: View {
    
    @Binding var currentStep: Int
    var steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Slider(value: Binding(
                get: { Double(currentStep) },
                set: { newValue in
                    currentStep = max(1, min(steps.count, Int(newValue.rounded())))
                }
            ), in: 1...Double(steps.count), step: 1)
            .tint(AppTheme.primary)
            .accessibilityLabel("Setup progress")
            
            HStack {
                Text("Start")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Finish")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

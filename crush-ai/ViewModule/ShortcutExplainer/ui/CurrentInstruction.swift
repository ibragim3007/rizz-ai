//
//  CurrentIns.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/4/25.
//

import SwiftUI

struct CurrentInstruction: View {
    @Binding var currentStep: Int
    var steps: [String]
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Step \(currentStep) of \(steps.count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(steps[currentStep - 1])
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .foregroundColor(AppTheme.fontMain)
        .padding(.top, 4)
    }
}

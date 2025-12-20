//
//  ActionButtonFlow.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/4/25.
//

import SwiftUI

struct ActionButtonFlow: View {
    @State private var currentStep: Int = 1
    @State private var showCompleted: Bool = false
    private let steps: [String] = [
        "Open Settings",
        "Tap Action Button",
        "Swipe through actions and select Shortcut",
        "Tap Choose Shortcut",
        "Select “Get Reply”",
    ]
    
    var body: some View {
        ZStack {
            MeshedGradient()
            
            VStack(spacing: 15) {
                Spacer()
                FlowHeader(title: "Set Up Action Button", subtext: "Follow these steps to assign Action Button “Get Reply”.")
                
                Spacer()
                illustration
                
                CurrentInstruction(currentStep: $currentStep, steps: steps)
                Spacer()
                //                progressSlider
                
                StepsListCard(steps: steps, currentStep: $currentStep)
                Spacer()
                
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: currentStep)
        .onChange(of: currentStep) { _, _ in
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
        }
        .alert("All set!", isPresented: $showCompleted) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your Action Button is now set to “Get Reply.” Try it by pressing your iPhone’s Action Button.")
        }
    }
    
    private var illustration: some View {
        ZStack {
            HStack(spacing: 16) {
                Image(systemName: "iphone.gen3")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppTheme.primaryLight, .white.opacity(0.9))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                
                Image(systemName: "hand.tap.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppTheme.primary, .white.opacity(0.9))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
            }
            .shadow(color: AppTheme.glow.opacity(0.5), radius: 18, x: 0, y: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
    
    // MARK: - Action buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if currentStep < steps.count {
                    currentStep += 1
                } else {
                    showCompleted = true
                }
#if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            } label: {
                HStack(spacing: 10) {
                    Text(currentStep < steps.count ? "Next Step" : "Done")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Image(systemName: currentStep < steps.count ? "arrow.right.circle.fill" : "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .white.opacity(0.20))
                        .font(.system(size: 20))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.glow.opacity(0.45), radius: 18, x: 0, y: 10)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
}

#Preview {
    ActionButtonFlow()
}

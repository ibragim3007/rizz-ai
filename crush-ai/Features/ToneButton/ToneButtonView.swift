//
//  ToneButtonView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI

struct ToneButtonView: View {
    
    @AppStorage("tone") private var currentTone: ToneTypes = .RIZZ
    
    // Явный порядок переключения
    private let orderedTones: [ToneTypes] = [.RIZZ, .ROMANTIC, .FLIRT, .NSFW]
    
    var body: some View {
        Button(action: {
            cycleTone()
        }) {
            Text(getToneName(tone: currentTone))
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 55, height: 55)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .background(
            Circle()
                .fill(AppTheme.primary.opacity(1))
        )
        .clipShape(Circle())
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 8, x: 0, y: 4)
        .accessibilityLabel("Change tone")
        .accessibilityValue(accessibilityToneName(for: currentTone))
        .accessibilityAddTraits(.isButton)
    }
    
    private func cycleTone() {
        if let idx = orderedTones.firstIndex(of: currentTone) {
            let nextIndex = orderedTones.index(after: idx)
            currentTone = nextIndex < orderedTones.endIndex ? orderedTones[nextIndex] : orderedTones.first!
        } else {
            currentTone = orderedTones.first!
        }
    }
    
    func getToneName(tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ:
            return "😎"
        case .ROMANTIC:
            return "💕"
        case .FLIRT:
            return "🫦"
        case .NSFW:
            return "😈"
        }
    }
    
    private func accessibilityToneName(for tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ: return "Rizz"
        case .ROMANTIC: return "Romantic"
        case .FLIRT: return "Flirt"
        case .NSFW: return "NSFW"
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground
        HStack {
            ToneButtonView()
            
            PrimaryCTAButton(title: "Hello world") {
                
            }
        }
    }
}

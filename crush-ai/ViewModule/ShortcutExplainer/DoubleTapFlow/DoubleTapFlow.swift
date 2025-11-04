//
//  DoubleTapFlow.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/3/25.
//

import SwiftUI

struct DoubleTapFlow: View {
    @State private var currentStep: Int = 1
    @State private var showCompleted: Bool = false
    @State private var showHint: Bool = false

    private let steps: [String] = [
        "Open Settings",
        "Go to Accessibility",
        "Tap Touch",
        "Select Back Tap",
        "Choose Double Tap",
        "Scroll Down Pick “Quick Reply”"
    ]

    var body: some View {
        ZStack {
            MeshedGradient()

            VStack(spacing: 15) {
                Spacer()
                header

                Spacer()
                illustration

                currentInstruction
                Spacer()
//                progressSlider

                stepsListCard
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
            Text("Your Double Tap is now configured to “Quick Reply”. You can try it by double-tapping the back of your iPhone.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Text("Set Up Double Tap")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.primaryGradient)
                .shadow(color: AppTheme.primary.opacity(0.45), radius: 16, x: 0, y: 6)

            Text("Follow these steps to assign Double Tap to “Quick Reply”.")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Illustration

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

    // MARK: - Current instruction

    private var currentInstruction: some View {
        VStack(spacing: 6) {
            Text("Step \(currentStep) of \(steps.count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(steps[currentStep - 1])
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
    }

    // MARK: - Slider

    private var progressSlider: some View {
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

    // MARK: - Steps list styled as a card

    private var stepsListCard: some View {
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
                        .foregroundStyle(done ? .white : .secondary)

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
                    Divider().overlay(Color.white.opacity(0.12)).padding(.leading, 28)
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
        .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
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
                    Image(systemName: currentStep < steps.count ? "arrow.right.circle.fill" : "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .white.opacity(0.45))
                    Text(currentStep < steps.count ? "Next Step" : "Done")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
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


            if showHint {
                Text("Path: Settings → Accessibility → Touch → Back Tap → Double Tap → “Quick Reply”.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.top, 6)
    }
}

#Preview {
    DoubleTapFlow()
        .preferredColorScheme(.dark)
}

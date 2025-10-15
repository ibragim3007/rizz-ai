//
//  Untitled.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import SwiftUI

struct EmptyDialogsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header / Illustration block
                ZStack {
                    // Card background with subtle depth
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
//                        )
                    
                    HStack(spacing: 18) {
                        Image("girl-4")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 110, maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Getting Started")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("Create your first conversation in three simple steps.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                }
                
                // Steps
                VStack(spacing: 16) {
                    StepCard(
                        number: 1,
                        title: "Upload a screenshot",
                        subtitle: "Choose or drag & drop a screenshot to start a new dialog.",
                        systemImage: "photo.on.rectangle.angled"
                    )
                    
                    StepCard(
                        number: 2,
                        title: "Tap \"Get Reply\"",
                        subtitle: "We’ll analyze the content and prepare a tailored response.",
                        systemImage: "sparkles"
                    )
                    
                    StepCard(
                        number: 3,
                        title: "Enjoy the result",
                        subtitle: "Review, refine, and continue the conversation effortlessly.",
                        systemImage: "face.smiling"
                    )
                }
                
                // Footer hint
                Text("Pro tip: You can add more screenshots later to improve context.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
            .padding(.vertical, 28)
        }
    }
}

// MARK: - Step Card

private struct StepCard: View {
    let number: Int
    let title: String
    let subtitle: String
    let systemImage: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            NumberBadge(number: number)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                        //                        .foregroundStyle(AppTheme.primary)
                            .accessibilityHidden(true)
                            .symbolRenderingMode(.monochrome)
                            .symbolEffect(.wiggle.up)
                    } else {
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .semibold))
                        //                        .foregroundStyle(AppTheme.primary)
                            .accessibilityHidden(true)
                            .symbolRenderingMode(.monochrome)
                    }
                    
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
        )
        .shadow(color: AppTheme.glow.opacity(0.18), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Number Badge

private struct NumberBadge: View {
    let number: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    Circle()
                        .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                )
            Text("\(number)")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(width: 36, height: 36)
        .accessibilityHidden(true)
    }
}


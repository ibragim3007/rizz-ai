//
//  StatisticsContent.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 11/5/25.
//

import SwiftUI

struct StatisticsContent: View {
    
    private let metrics: [CompareMetric] = [
        .init(title: "Replies", base: 12, crush: 84),          // ×7
        .init(title: "Conversations Started", base: 5, crush: 32),               // ×4
        .init(title: "Dates", base: 2, crush: 9, highlight: true),                                // ×3           // ×4
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    chartCard
//                    subtex t
                    benefitGrid
                }
                .padding(.horizontal, 20)
//                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("How Wingman AI boosts your results")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.fontMain)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 6)
        .padding(.bottom, 4)
    }
    
    // MARK: - Chart Card
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Legend
            HStack(spacing: 14) {
                LegendDot(color: AppTheme.fontMain.opacity(0.28))
                Text("Without Wingman AI")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain.opacity(0.7))
                LegendDot(color: AppTheme.primary)
                Text("With Wingman AI")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain.opacity(0.9))
                Spacer()
            }
            .padding(.bottom, 2)
            
            VStack(spacing: 10) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                    // Пошаговая (staggered) задержка для приятного появления
                    CompareBarRow(metric: metric, delay: Double(index) * 0.5)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.fontMain.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
        )
    }
    
    // MARK: - Subtext
    private var subtext: some View {
        Text("With Crush AI you get up to 7× more replies, move into conversations faster, and land more dates. The AI crafts strong openers and helps maintain interest less effort, more results for you.")
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundStyle(AppTheme.fontMain.opacity(0.8))
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 4)
    }
    
    // MARK: - Benefits
    private var benefitGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your benefits with Wingman AI")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.fontMain.opacity(0.9))
            
            VStack(spacing: 10) {
                BenefitRow(icon: "bolt.fill",
                           title: "Up to 7× more replies",
                           subtitle: "Stronger openers and smart follow‑ups.")
                BenefitRow(icon: "message.fill",
                           title: "Faster to conversations",
                           subtitle: "Keep interest and move into real chats.")
                BenefitRow(icon: "heart.fill",
                           title: "More dates",
                           subtitle: "Get prompts for when and how to ask for a date.")
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(AppTheme.fontMain.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
            )
        }
        .padding(.top, 6)
    }
}

// MARK: - Models

private struct CompareMetric: Identifiable {
    let id = UUID()
    let title: String
    let base: Double
    let crush: Double
    var highlight: Bool = false
    
    var multiplierText: String {
        guard base > 0 else { return "×—" }
        let mult = crush / base
        // Round to 1 decimal for readability
        if mult >= 10 {
            return "×\(Int(mult.rounded()))"
        } else {
            return "×\(String(format: "%.1f", mult))"
        }
    }
}

// MARK: - Components

private struct CompareBarRow: View {
    let metric: CompareMetric
    let delay: Double
    
    @State private var animateBars = false
    
    init(metric: CompareMetric, delay: Double = 0) {
        self.metric = metric
        self.delay = delay
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(metric.title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.fontMain.opacity(0.9))
                Spacer()
                if metric.highlight {
                    Text(metric.multiplierText)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(AppTheme.primary)
                        )
                        .accessibilityLabel("Increase \(metric.multiplierText)")
                }
            }
            
            // Bars
            PairBars(base: metric.base, crush: metric.crush, animate: animateBars)
        }
        .padding(.vertical, 6)
        .onAppear {
            // Сначала обнуляем (на случай повторного показа), затем запускаем анимацию с задержкой
            animateBars = false
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
                    animateBars = true
                }
            }
        }
        .onDisappear {
            // Чтобы при повторном появлении снова анимировалось
            animateBars = false
        }
    }
}

private struct PairBars: View {
    let base: Double
    let crush: Double
    let animate: Bool
    
    private var maxValue: Double {
        max(max(base, crush), 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Base (Without Crush AI)
            HStack(spacing: 10) {
                Capsule()
                    .fill(AppTheme.fontMain.opacity(0.28))
                    .frame(width: barWidth(for: base, animated: animate), height: 12)
                    .overlay(
                        Capsule().stroke(AppTheme.fontMain.opacity(0.18), lineWidth: 1)
                    )
                Text(valueText(base))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain.opacity(0.8))
                Spacer(minLength: 0)
            }
            
            // Crush (With Crush AI)
            HStack(spacing: 10) {
                Capsule()
                    .fill(AppTheme.primary)
                    .overlay(
                        LinearGradient(colors: [AppTheme.fontMain.opacity(0.12), .clear],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                            .clipShape(Capsule())
                    )
                    .frame(width: barWidth(for: crush, animated: animate), height: 14)
                    .overlay(
                        Capsule().stroke(AppTheme.fontMain.opacity(0.18), lineWidth: 1)
                    )
                Text(valueText(crush))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain)
                Spacer(minLength: 0)
            }
        }

        // Анимация запускается, когда переключается флаг animate
        .animation(.spring(response: 0.6, dampingFraction: 0.9), value: animate)
    }
    
    private func barWidth(for value: Double, animated: Bool) -> CGFloat {
        // Normalize within the pair; keep a minimum for visibility
        let minWidth: CGFloat = 18
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 20*2 - 16*2 - 60 // account for paddings/text
        guard maxValue > 0 else { return minWidth }
        let effectiveValue = animated ? value : 0
        let ratio = CGFloat(effectiveValue / maxValue)
        return max(minWidth, ratio * maxWidth)
    }
    
    private func valueText(_ value: Double) -> String {
        if value == floor(value) {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

private struct LegendDot: View {
    let color: Color
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(
                Circle().stroke(AppTheme.fontMain.opacity(0.18), lineWidth: 1)
            )
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.fontMain.opacity(0.06))
                    .frame(width: 36, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.fontMain.opacity(0.75))
            }
            Spacer()
        }
    }
}

#Preview {
    StatisticsContent()
        .preferredColorScheme(.light)
}

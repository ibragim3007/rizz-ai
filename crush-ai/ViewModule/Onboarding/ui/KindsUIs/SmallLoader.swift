//
//  SmallLoader.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/3/25.
//

import SwiftUI

struct SmallLoader: View {
    let title: String
    let duration: TimeInterval
    let onFinish: () -> Void

    @State private var progress: CGFloat = 0
    @State private var started = false
    @State private var sleeper: Task<Void, Never>?
    @State private var ticker: Task<Void, Never>?

    // Частицы для «живости»
    @State private var particles: [Particle] = Particle.make(count: 16)

    init(
        title: String = "Analyzing your answers...",
        duration: TimeInterval = 6,
        onFinish: @escaping () -> Void = {}
    ) {
        self.title = title
        self.duration = duration
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            ZStack {
                // Мягкая аура позади бара
//                AuraBackground()

                // Сам прогресс-бар
                CapsuleProgressBar(
                    progress: progress,
                    particles: particles
                )
                .frame(height: 32)

                // Проценты по центру
                Text("\(Int(progress * 100))%")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            guard !started else { return }
            started = true
            progress = 0

            // Нелинейная «умная» подкачка прогресса с микро-паузами
            ticker = Task {
                let start = Date()
                while !Task.isCancelled {
                    let elapsed = Date().timeIntervalSince(start)
                    let t = min(1.0, elapsed / duration)
                    let target = easeOutCubic(t)

                    if t >= 1.0 {
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 1.15)) {
                                progress = 1.0
                            }
                        }
                        break
                    } else {
                        // Небольшие случайные шажки и паузы — «живая» анимация
                        let delay = Double.random(in: 0.2...0.45)
                        let maxStep = 0.20
                        let minStep = 0.025
                        let step = CGFloat(Double.random(in: minStep...maxStep))
                        let nextValue = min(CGFloat(target), progress + step)

                        await MainActor.run {
                            withAnimation(.easeInOut(duration: delay)) {
                                progress = nextValue
                            }
                        }

                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                }
            }

            // По окончании общего времени — вызываем onFinish
            sleeper = Task {
                do {
                    try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    if !Task.isCancelled {
                        await MainActor.run { onFinish() }
                    }
                } catch { /* cancelled */ }
            }
        }
        .onDisappear {
            sleeper?.cancel()
            ticker?.cancel()
        }
    }

    // Нелинейная кривая: ease-out (кубическая)
    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - t, 2)
    }
}

// MARK: - Частицы

private struct Particle: Identifiable {
    let id = UUID()
    let seed: Double
    let speed: Double
    let size: CGFloat
    let hueShift: Double

    static func make(count: Int) -> [Particle] {
        (0..<count).map { _ in
            Particle(
                seed: Double.random(in: 0...10_000),
                speed: Double.random(in: 0.35...0.85),
                size: CGFloat.random(in: 3.5...6.5),
                hueShift: Double.random(in: -0.02...0.02)
            )
        }
    }
}

// MARK: - Аура позади бара

private struct AuraBackground: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.primary.opacity(AppTheme.auraCenterOpacity))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(y: 6)
                .blendMode(.plusLighter)

            Circle()
                .fill(AppTheme.primaryLight.opacity(AppTheme.auraBottomOpacity))
                .frame(width: 420, height: 420)
                .blur(radius: 140)
                .offset(y: 70)
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Капсульный прогресс-бар с шимером и частицами

private struct CapsuleProgressBar: View {
    let progress: CGFloat
    let particles: [Particle]

    var body: some View {
        ZStack {
            // Контейнер «стекло» с тонким штрихом
            GeometryReader { geo in
                let h = geo.size.height
                let r = h / 2

                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        // Лёгкий тинт темным оттенком темы
                        RoundedRectangle(cornerRadius: r, style: .continuous)
                            .fill(AppTheme.primaryDark.opacity(0.18))
                    )
                    .overlay(
                        // Тонкий стеклянный штрих
                        RoundedRectangle(cornerRadius: r, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.28),
                                        .white.opacity(0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
                    .shadow(color: AppTheme.glow.opacity(0.25), radius: 22, x: 0, y: 10)
            }

            // Заполнение
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let r = h / 2
                let filled = max(h, w * progress)

                ZStack(alignment: .leading) {
                    // Градиентная заливка
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.primary,
                                    AppTheme.primaryLight
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: filled)
                        .shadow(color: AppTheme.glow.opacity(0.35), radius: 16, x: 0, y: 0)

                    // Верхний световой отблеск
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.25),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: filled)
                        .blendMode(.screen)
                        .opacity(0.5)

                    // Шимер — бегущая световая полоса
                    ShimmerStripe(width: filled, height: h)
                        .frame(width: filled, height: h)
                        .mask(
                            RoundedRectangle(cornerRadius: r, style: .continuous)
                        )

                    // Частицы внутри заполненной области
                    ParticlesLayer(particles: particles, width: filled, height: h)
                        .frame(width: filled, height: h)
                        .mask(
                            RoundedRectangle(cornerRadius: r, style: .continuous)
                        )
                }
            }
        }
    }
}

// MARK: - Шимер

private struct ShimmerStripe: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            // Период движения
            let period: Double = 1.8
            let phase = t.truncatingRemainder(dividingBy: period) / period
            let stripeWidth = height * 1.6
            let travel = width + stripeWidth * 2
            let x = -stripeWidth + travel * phase

            LinearGradient(
                colors: [
                    .white.opacity(0.0),
                    .white.opacity(0.75),
                    .white.opacity(0.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: stripeWidth, height: height * 1.6)
            .rotationEffect(.degrees(18))
            .offset(x: x)
            .blendMode(.screen)
            .opacity(0.65)
        }
    }
}

// MARK: - Частицы

private struct ParticlesLayer: View {
    let particles: [Particle]
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                guard width > 0 else { return }

                for p in particles {
                    // Движение внутри заполненной области
                    let base = (sin(t * p.speed + p.seed) + 1) / 2 // 0...1
                    let x = base * width
                    let yOsc = sin(t * (p.speed * 1.2) + p.seed * 1.7)
                    let y = size.height / 2 + yOsc * (size.height * 0.28)

                    let rect = CGRect(
                        x: x - p.size / 2,
                        y: y - p.size / 2,
                        width: p.size,
                        height: p.size
                    )

                    let dot = Path(ellipseIn: rect)

                    // Лёгкое мерцание
                    let alpha = 0.55 + 0.75 * (sin(t * (0.8 + p.speed) + p.seed) + 1) / 2
                    let color = AppTheme.primaryLight
                        .opacity(alpha)

                    context.fill(dot, with: .color(color))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        SmallLoader {
            print("Finished!")
        }
        .preferredColorScheme(.dark)
        .padding(.vertical, 40)
    }
}

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
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 28)

                GeometryReader { geo in
                    let width = max(28, geo.size.width * progress)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width, height: 28)
                        .shadow(color: AppTheme.glow.opacity(0.35), radius: 10, x: 0, y: 0)
                }
                .frame(height: 28)

                Text("\(Int(progress * 100))%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            guard !started else { return }
            started = true
            progress = 0

            // Рывками повышаем прогресс по нелинейной кривой (ease-out)
            ticker = Task {
                let start = Date()
                while !Task.isCancelled {
                    let elapsed = Date().timeIntervalSince(start)
                    let t = min(1.0, elapsed / duration)
                    let target = easeOutCubic(t)

                    if t >= 1.0 {
                        await MainActor.run {
                            withAnimation(.easeOut(duration: 0.2)) {
                                progress = 1.0
                            }
                        }
                        break
                    } else {
                        // Небольшой случайный шаг и задержка, чтобы было «прерывно»
                        let delay = Double.random(in: 0.06...0.22)
                        let maxStep = 0.12
                        let minStep = 0.03
                        let step = CGFloat(Double.random(in: minStep...maxStep))

                        let nextValue = min(CGFloat(target), progress + step)

                        await MainActor.run {
                            withAnimation(.easeOut(duration: delay)) {
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
        1 - pow(1 - t, 3)
    }
}

#Preview {
    ZStack {
        SmallLoader {
            print("Finished!")
        }.preferredColorScheme(.dark)
    }
}

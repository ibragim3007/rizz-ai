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

    init(
        title: String = "Analyzing your answers...",
        duration: TimeInterval = 3,
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
                                colors: [.purple, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width, height: 28)
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

            withAnimation(.linear(duration: duration)) {
                progress = 1
            }

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
        }
        .background(
            LinearGradient(colors: [Color.black, Color.purple.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SmallLoader {
            print("Finished!")
        }
    }
}

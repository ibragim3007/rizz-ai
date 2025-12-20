//
//  RateUsUI.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/6/25.
//

import SwiftUI
import StoreKit

struct RateUsUI: View {
    let title: String
    let subtext: String
    let icon: String

    // iOS 16+: удобный способ запросить оценку
    @Environment(\.requestReview) private var requestReview
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            content
                .task {
                    // Задержка 2 секунды перед показом запроса оценки
                    try? await Task.sleep(nanoseconds: 1_700_000_000)
                    await MainActor.run {
                        // Используем универсальную функцию, чтобы корректно работать на разных версиях iOS
                        askForReview()
                    }
                }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            
            Spacer(minLength: 0)

            header
                .foregroundColor(AppTheme.fontMain)
            
            Spacer()

            iconCard

            Spacer()

            starsRow
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 36, design: .rounded))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(subtext)
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var iconCard: some View {
        ZStack {
            Image("crush-letter")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 250, height: 250)
        .padding(.horizontal, 30)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private var starsRow: some View {
        HStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.35), radius: 8, x: 0, y: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Five star rating illustration")
    }


    private func askForReview() {
        if #available(iOS 16.0, *) {
            requestReview()
        } else {
            #if os(iOS)
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                // Фолбэк на случай отсутствия активной сцены
                SKStoreReviewController.requestReview()
            }
            #endif
        }
    }
}

#Preview {
    RateUsUI(
        title: "Help us grow!",
        subtext: "Be one of the first to rate us!",
        icon: "app-icon" // подставьте имя ассета с иллюстрацией/иконкой
    )
}

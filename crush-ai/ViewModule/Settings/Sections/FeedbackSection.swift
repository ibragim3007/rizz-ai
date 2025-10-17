//
//  FeedbackSection.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/17/25.
//

import SwiftUI
import StoreKit


struct FeedbackSection: View {
    
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            rateApp()
        } label: {
            HStack {
                Text(NSLocalizedString("🤩 Rate the app", comment: "Rate the app button"))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(
            PrimaryGradientButtonStyleShimmer(
                isShimmering: true,
                cornerRadius: 0
            )
        )
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            reportProblem()
        } label: {
            HStack {
                Text(NSLocalizedString("Report a problem", comment: "Report a problem button"))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens email with your user ID")
    }
    
    
    private func rateApp() {
#if canImport(UIKit)
        // Сначала пробуем системный запрос оценки в текущей сцене
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
            return
        }
#endif
        // Фоллбэк — прямая ссылка на страницу оценки в App Store
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreID)?action=write-review") {
            openURL(url)
        }
    }
    
    private func reportProblem() {
        let userID = paywallViewModel.appUserID
        let subject = "Crush AI – Support request"
        // Можно добавить больше контекста в тело письма
        let body = """
        Hello team,
        
        I would like to report an issue.
        
        RevenueCat user id: \(userID)
        
        Details:
        """
        guard let mailto = makeMailtoURL(
            to: supportEmail,
            subject: subject,
            body: body
        ) else { return }
        openURL(mailto)
    }
    
    private func makeMailtoURL(to: String, subject: String, body: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }
    
    
}

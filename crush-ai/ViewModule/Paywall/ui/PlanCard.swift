//
//  PlanCard.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/20/25.
//

import SwiftUI

public struct PlanCard<Selection: Equatable>: View {
    // Внешний выбор
    @Binding private var selected: Selection
    // Значение, соответствующее этой карточке
    private let plan: Selection
    
    // Контент
    private let titlePrefix: String
    private let title: String
    private let subtitle: String
    private let badge: String?
    
    // Init
    public init(
        selected: Binding<Selection>,
        plan: Selection,
        titlePrefix: String = "",
        title: String,
        subtitle: String,
        badge: String? = nil
    ) {
        self._selected = selected
        self.plan = plan
        self.titlePrefix = titlePrefix
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }
    
    public var body: some View {
        let isSelected = selected == plan
        
        Button {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                selected = plan
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.primaryDark.opacity(isSelected ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                isSelected
                                ? LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                : AppTheme.borderPrimaryGradient,
                                lineWidth: 2
                            )
                    )
                
                if let badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.primary)
                        .clipShape(Capsule())
                        .offset(x: -14, y: -12)
                }
                
                HStack(alignment: .center, spacing: 14) {
                    // Radio
                    ZStack {
                        Circle()
                            .fill(AppTheme.fontMain.opacity(0.10))
                            .frame(width: 36, height: 36)
                        if isSelected {
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .stroke(AppTheme.fontMain.opacity(0.8), lineWidth: 3)
                                .frame(width: 26, height: 26)
                        }
                    }
                    .padding(.leading, 12)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            if !titlePrefix.isEmpty {
                                Text(titlePrefix)
                            }
                            Text(title)
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.fontMain)
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.fontMain.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 8)
                }
                .padding(.vertical, 18)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title)"))
        .accessibilityHint(Text(isSelected ? "Selected" : "Tap to select"))
    }
}
#if DEBUG
import SwiftUI

private enum PreviewPlan: String, CaseIterable, Equatable {
    case monthly
    case yearly
}

#Preview("PlanCard variations") {
    @State var selected: PreviewPlan = .monthly

    return VStack(spacing: 16) {
        PlanCard(
            selected: $selected,
            plan: .monthly,
            titlePrefix: "Monthly",
            title: "$9.99",
            subtitle: "Billed monthly. Cancel anytime.",
            badge: "Popular"
        )
        .padding(.horizontal)

        PlanCard(
            selected: $selected,
            plan: .yearly,
            titlePrefix: "Yearly",
            title: "$59.99",
            subtitle: "Save 50% vs monthly billing",
            badge: nil
        )
        .padding(.horizontal)
    }
    .frame(maxHeight: 200)
    .padding(.vertical)
}
#endif


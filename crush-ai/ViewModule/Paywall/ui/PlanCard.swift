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
                    .fill(.white.opacity(isSelected ? 0.10 : 0.06))
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
                    .shadow(color: AppTheme.glow.opacity(isSelected ? 0.35 : 0.0), radius: 16, x: 0, y: 8)
                
                if let badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.red)
                        .clipShape(Capsule())
                        .offset(x: -14, y: -12)
                }
                
                HStack(alignment: .center, spacing: 14) {
                    // Radio
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 36, height: 36)
                        if isSelected {
                            Circle()
                                .fill(AppTheme.primary)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .stroke(.white.opacity(0.8), lineWidth: 3)
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
                        .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
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

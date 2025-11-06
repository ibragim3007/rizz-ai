//
//  Untitled.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import SwiftUI

struct EmptyDialogsView: View {
    // Минимальный набор анимаций
    @State private var showHero = false
    @State private var showChips = false
    
    // Статичное изображение
    private let heroImages = ["welcome-image-1", "welcome-image-2", "welcome-image-3"]
    
    // Единый вход в поток импорта
    var onImportTapped: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Hero / Illustration block
            VStack (spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                        )
                    
                    ZStack(alignment: .bottomTrailing) {
                        
                        Image(heroImages.first ?? "welcome-image-1")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                        
                        
                            LinearGradient(
                                colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(maxHeight: 150)
                        
                        VStack {
                            ReplyView(content: "keep texting like that and i might start charging rent for my attention", tone: .RIZZ)
                        }
                        .scaleEffect(0.65)
                        .offset(x: 50, y: -5)

                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    
                }
                .opacity(showHero ? 1 : 0)
                .animation(.snappy(duration: 0.6), value: showHero)
                
                Spacer(minLength: 20)
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start a new dialog")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Drop a screenshot — we’ll do the rest.")
                        .font(.system(.subheadline, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                Spacer()
                
                FlowChipsVertical(
                    show: showChips,
                    onImport: onImportTapped
                )
                .animation(.snappy(duration: 0.5), value: showChips)
                .padding(.horizontal, 20)
            }
            
            // Главное действие
            //            ShortcutButton()
            //                .opacity(showHero ? 1 : 0)
            //                .offset(y: showHero ? 0 : 10)
            //                .animation(.snappy(duration: 0.5).delay(0.05), value: showHero)
        }
        .padding(.vertical, 28)
        .task {
            await animateIn()
        }
    }
    
    // MARK: - Simple animation
    
    private func animateIn() async {
        showHero = false
        showChips = false
        
        try? await Task.sleep(nanoseconds: 120_000_000)
        withAnimation(.snappy(duration: 0.6)) { showHero = true }
        
        try? await Task.sleep(nanoseconds: 120_000_000)
        withAnimation(.snappy(duration: 0.5)) { showChips = true }
    }
}

// MARK: - Vertical flow chips column (Timeline)

private struct FlowChipsVertical: View {
    let show: Bool
    let onImport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1) Import screenshot — active & interactive
            TimelineStepRow(
                index: 0,
                isFirst: true,
                isLast: false,
                state: .active,
                title: "Import screenshot",
                icon: "photo.on.rectangle.angled",
                action: {
#if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
                    onImport()
                }
            )
            
            // 2) Analyze — upcoming
            TimelineStepRow(
                index: 1,
                isFirst: false,
                isLast: false,
                state: .upcoming,
                title: "Analyze",
                icon: "sparkles"
            )
            
            // 3) Copy reply — upcoming
            TimelineStepRow(
                index: 2,
                isFirst: false,
                isLast: true,
                state: .upcoming,
                title: "Copy reply",
                icon: "doc.on.doc"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(show ? 1 : 0)
        //        .offset(y: show ? 0 : 10)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Timeline row

private enum StepState {
    case active
    case completed
    case upcoming
}

private struct TimelineStepRow: View {
    let index: Int
    let isFirst: Bool
    let isLast: Bool
    let state: StepState
    let title: String
    let icon: String
    var action: (() -> Void)? = nil
    
    // Размеры
    private let railWidth: CGFloat = 44
    private let circleSize: CGFloat = 25
    private let innerDot: CGFloat = 7
    private let corner: CGFloat = 18
    
    // Анимации взаимодействия
    @GestureState private var isPressed: Bool = false
    @State private var pulse: Bool = false
    @State private var shakePhase: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left rail + marker
            ZStack {
                // Верхняя часть линии (до кружка)
                if !isFirst {
                    Rectangle()
                        .fill(railColor.opacity(state == .upcoming ? 0.25 : 1))
                        .frame(width: 3)
                        .offset(y: -circleSize/2 - 16)
                        .frame(maxHeight: 32, alignment: .top)
                }
                // Нижняя часть линии (после кружка)
                if !isLast {
                    Rectangle()
                        .fill(railColor.opacity(state == .upcoming ? 0.25 : 1))
                        .frame(width: 3)
                        .offset(y: circleSize/2 + 6)
                        .frame(maxHeight: 10, alignment: .bottom)
                }
                
                // Маркер шага
                ZStack {
                    Circle()
                        .fill(markerFill)
                        .overlay(
                            Circle()
                                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                                .opacity(0.9)
                        )
                    
                    Circle()
                        .fill(innerFill)
                        .frame(width: innerDot, height: innerDot)
                }
                .frame(width: circleSize, height: circleSize)
            }
            .frame(width: railWidth, height: 54)
            
            // Content card
            contentCard
                .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .onTapGesture {
                    action?()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.0)
                        .updating($isPressed) { _, state, _ in
                            state = true
                        }
                )
                .accessibilityLabel("\(title)")
                .accessibilityAddTraits(state == .active ? .isButton : [])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            // Мягкое пульсирующее свечение и легкая дрожь только для активного шага
            guard state == .active else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                shakePhase = 1
            }
        }
    }
    
    // MARK: - Content card
    
    @ViewBuilder
    private var contentCard: some View {
        let isActive = (state == .active)
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(isActive ? .white : .white.opacity(0.85))
                .accessibilityHidden(true)
            
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(isActive ? .white : .white.opacity(0.92))
            
            Spacer(minLength: 0)
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        .background(
            Group {
                if isActive {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(AppTheme.primaryGradient)
                } else {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(Color.white.opacity(0.03))
                }
            }
        )
        .buttonStyle(PrimaryGradientButtonStyleShimmer(isShimmering: true))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                .opacity(isActive ? 1.0 : 0.8)
        )
        // Иконка "tap" справа как подсказка (только для активного шага)
        .overlay(alignment: .trailing) {
            if isActive {
                Image(systemName: "hand.tap")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.trailing, 16)
            }
        }
        .scaleEffect(isActive && isPressed ? 0.97 : 1.0)
        // Легкая дрожь по оси X
        .modifier(
            isActive
            ? ShakeEffect(amount: 1.5, shakesPerUnit: 1.2, animatableData: shakePhase)
            : ShakeEffect(amount: 0, shakesPerUnit: 0, animatableData: 0)
        )
        .animation(.snappy(duration: 0.15), value: isPressed)
    }
    
    // MARK: - Colors
    
    private var railColor: Color {
        switch state {
        case .completed, .active: return AppTheme.primary
        case .upcoming: return .white
        }
    }
    
    private var markerFill: Color {
        switch state {
        case .active: return AppTheme.primary
        case .completed: return AppTheme.primary.opacity(0.25)
        case .upcoming: return Color.white.opacity(0.06)
        }
    }
    
    private var innerFill: Color {
        switch state {
        case .active: return .white
        case .completed: return AppTheme.primary
        case .upcoming: return .white.opacity(0.55)
        }
    }
    
    private var markerShadow: Color {
        switch state {
        case .active: return AppTheme.glow.opacity(0.45)
        case .completed: return AppTheme.glow.opacity(0.25)
        case .upcoming: return .black.opacity(0.25)
        }
    }
}

// MARK: - Легкий shake-эффект

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 2
    var shakesPerUnit: CGFloat = 1.5
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * 2 * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Legacy chip (kept for reference; not used now)

private struct Chip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .accessibilityHidden(true)
            
            Text(text)
                .font(.system(.subheadline, design: .rounded))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
        )
    }
}

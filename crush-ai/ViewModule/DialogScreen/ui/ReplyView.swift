//
//  ReplyView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import SwiftUI

struct ReplyView: View {
    
    var content: String
    var tone: ToneTypes
    
    @State private var didCopy: Bool = false
    @State private var wasCopied: Bool = false
    @State private var shakeTrigger: CGFloat = 0 // триггер для анимации «вздрагивания»
    
    var body: some View {
        Text(content)
            .font(.system(size: 17, weight: .semibold, design: .default))
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .lineSpacing(4)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                BubbleShape(cornerRadius: cornerRadius)
                    .fill(gradientForTone)
                    .saturation(wasCopied ? 0.5 : 1)
            )
            // Лёгкий «глянец», чтобы пузырёк выглядел живым
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity(0.1),
                        .white.opacity(0.15),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(BubbleShape(cornerRadius: cornerRadius))
            )
            // Небольшой водяной знак с тоном внизу справа — почти не отвлекает
            .overlay(alignment: .bottomTrailing) {
                Text(getToneName(tone: tone))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(0.5)
                    .padding(8)
                    .accessibilityHidden(true)
            }
            // Всплывающий тост «Copied»
            .overlay(alignment: .topTrailing) {
                if didCopy {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .white.opacity(0.45))
                        Text("Copied")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity.combined(with: .scale(scale: 0.6)))
                    .padding(10)
                }
            }
            .contentShape(BubbleShape(cornerRadius: cornerRadius))
            // Объёмные тени
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
            // Лёгкое «вздрагивание» при копировании
            .modifier(ShakeEffect(amount: 3, shakesPerUnit: 2, animatableData: shakeTrigger))
            .onTapGesture(perform: copyToClipboard)
            .accessibilityLabel("Reply")
            .accessibilityHint("Double tap to copy")
            .accessibilityValue(accessibilityToneName(for: tone))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: "Copy") { copyToClipboard() }
    }
    
    // MARK: - Look & Feel
    
    private var cornerRadius: CGFloat { 22 }
    
    private var gradientForTone: LinearGradient {
        let colors: [Color]
        switch tone {
        case .RIZZ:
            // Индиго → электрик блю (как в примере)
            colors = [Color(hex: 0x6E37FF), Color(hex: 0x3B82F6)]
        case .FLIRT:
            // Игривый розовый → фиолетовый
            colors = [Color(hex: 0xFF5DA2), Color(hex: 0xB245FC)]
        case .ROMANTIC:
            // Тёплый коралл → персик
            colors = [Color(hex: 0xFF6B6B), Color(hex: 0xFFD166)]
        case .NSFW:
            // Дерзкий алый → тёмная магента
            colors = [Color(hex: 0xFF1E56), Color(hex: 0x7A1E6C)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var accentForTone: Color {
        switch tone {
        case .RIZZ:     return Color(hex: 0x6E37FF)
        case .FLIRT:    return Color(hex: 0xFF5DA2)
        case .ROMANTIC: return Color(hex: 0xFF6B6B)
        case .NSFW:     return Color(hex: 0xFF1E56)
        }
    }
    
    // MARK: - Copy
    
    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = content
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(content, forType: .string)
        #endif
        
        // Тост + вздрагивание
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            didCopy = true
            wasCopied = true
        }
        withAnimation(.easeOut(duration: 0.28)) {
            shakeTrigger += 1
        }
        
        // Автоматически скрываем тост
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                didCopy = false
            }
        }
    }
    
    // Для доступности — читабельное имя тона
    private func accessibilityToneName(for tone: ToneTypes) -> String {
        switch tone {
        case .RIZZ: return "Rizz"
        case .ROMANTIC: return "Romantic"
        case .FLIRT: return "Flirt"
        case .NSFW: return "NSFW"
        }
    }
}

// MARK: - Bubble shape with tail (bottom-right) + менее скруглённый правый нижний угол

private struct BubbleShape: Shape {
    var cornerRadius: CGFloat
    
    // Слегка уменьшаем правый нижний угол
    var bottomRightFactor: CGFloat = 0.5 // 60% от общего радиуса
    
    // Параметры хвостика
    var tailWidth: CGFloat = 10
    var tailHeight: CGFloat = 5
    var tailOffsetY: CGFloat = 0
    var tailInsetFromRight: CGFloat = -10
    
    func path(in rect: CGRect) -> Path {
        let tl = max(0, min(cornerRadius, min(rect.width, rect.height) / 2))
        let tr = tl
        let bl = tl
        let br = max(0, min(tl * bottomRightFactor, min(rect.width, rect.height) / 2))
        
        var path = Path()
        
        // Основа: скруглённый прямоугольник с индивидуальными радиусами
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        // Верхняя грань -> правый верхний
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                    radius: tr,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        // Правая грань -> правый нижний
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                    radius: br,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        // Нижняя грань -> левый нижний
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                    radius: bl,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        // Левая грань -> левый верхний
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                    radius: tl,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        path.closeSubpath()
        
        // Хвостик (чуть левее уменьшенного угла)
        let attachX = max(rect.minX + max(tl, tailWidth) + 6,
                          rect.maxX - max(br + 6, tailInsetFromRight + tailWidth) + 6)
        let baseY = rect.maxY - tailOffsetY
        
        let p1 = CGPoint(x: attachX, y: baseY)                     // правая точка крепления
        let p2 = CGPoint(x: attachX - tailWidth, y: baseY)         // левая точка крепления
        let tip = CGPoint(x: rect.maxX - 9, y: rect.maxY + tailHeight) // кончик
        let c1 = CGPoint(x: (p2.x + tip.x) / 2, y: rect.maxY + tailHeight * 1.0)
        let c2 = CGPoint(x: (p1.x + tip.x) / 2, y: rect.maxY + tailHeight * 0.9)
        
        var tail = Path()
        tail.move(to: p1)
        tail.addLine(to: p2)
        tail.addQuadCurve(to: tip, control: c1)
        tail.addQuadCurve(to: p1, control: c2)
        tail.closeSubpath()
        
        path.addPath(tail)
        return path
    }
}

// MARK: - Shake Effect

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8          // амплитуда
    var shakesPerUnit: CGFloat = 3   // «частота» дрожи
    var animatableData: CGFloat      // триггер (увеличиваем, чтобы проиграть анимацию)

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    VStack (spacing: 20) {
        ReplyView(
            content: "before I decide if you're worth my attention, what's your best pickup line for a guy who already knows he's amazing?",
            tone: .RIZZ
        )
        ReplyView(
            content: "If flirting were a sport, we'd both be in the finals.",
            tone: .FLIRT
        )
        ReplyView(
            content: "As long as I’m breathing, I’ll keep choosing you.",
            tone: .ROMANTIC
        )
        ReplyView(
            content: "Bold, unapologetic, and a little dangerous — say less.",
            tone: .NSFW
        )
    }
    .padding()
    .background(
        LinearGradient(
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
            startPoint: .top, endPoint: .bottom
        )
    )
}


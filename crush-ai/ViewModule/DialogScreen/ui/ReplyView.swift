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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(gradientForTone)
            )
            // Лёгкий «глянец», чтобы пузырёк выглядел живым
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity(0.28),
                        .white.opacity(0.10),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.softLight)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            // Едва заметная обводка для глубины
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
            // Всплывающий тост «Copied»
            .overlay(alignment: .topTrailing) {
                if didCopy {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .white.opacity(0.35))
                        Text("Copied")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.25), in: Capsule())
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .padding(10)
                }
            }
            // Объёмные тени
            .shadow(color: accentForTone.opacity(0.35), radius: 18, x: 0, y: 12)
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onTapGesture(perform: copyToClipboard)
            .accessibilityLabel("Reply")
            .accessibilityHint("Double tap to copy")
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
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            didCopy = true
        }
        // Автоматически скрываем тост
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                didCopy = false
            }
        }
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
    .preferredColorScheme(.dark)
}

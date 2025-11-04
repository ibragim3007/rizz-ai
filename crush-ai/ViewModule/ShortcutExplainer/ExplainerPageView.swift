// ui/ExplainerPageView.swift
import SwiftUI

struct ExplainerPageView: View {
    
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Spacer()
                Text("Reply Like a Pro")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text("Generate clever AI responses for any chat or post.")
                    Text("They’re already copied — just paste and send.")
                }
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
                        )
                        .shadow(color: AppTheme.glow.opacity(0.18), radius: 14, x: 0, y: 8)
                    
                    Image("shortcut-intro")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(12)
                        .accessibilityHidden(true)
                        .modifier(RippleEffect(at: origin, trigger: counter))
                        .onTapGesture { location in
                            origin = location
                            counter += 1
                        }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
            }
            .padding(.bottom, 120)
        }
    }
}

#Preview {
    ExplainerPageView().preferredColorScheme(.dark)
}

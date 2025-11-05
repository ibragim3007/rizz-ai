// ui/ChooseActivationPageView.swift
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ChooseActivationPageView: View {
    var onSelectActionButton: () -> Void = {}
    var onSelectDoubleTap: () -> Void = {}
    
    @State private var isDoubleTapFlowPresented: Bool = false
    @State private var isActionButtonFlowPresented: Bool = false
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Spacer()
                Text("Choose Activation")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.top, 20)
                
                VStack(spacing: 10) {
                    Text("Pick how you want to trigger the shortcut.")
                    Text("You can change this later in Settings.")
                }
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 14) {
                    activationCard(
                        title: "Action Button",
                        subtitle: "For iPhone 15 Pro and newer",
                        systemImage: "button.vertical.left.press",
                        isDisabled: false
                    ) {
                        
                        isActionButtonFlowPresented = true
                        
                    }
                    
                    activationCard(
                        title: "Double Tap",
                        subtitle: "Works on any iPhone",
                        systemImage: "hand.tap",
                        isDisabled: false
                    ) {
                        //                        onSelectDoubleTap()
                        isDoubleTapFlowPresented = true
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isDoubleTapFlowPresented) {
            NavigationStack {
                DoubleTapFlow()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isDoubleTapFlowPresented = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Close")
                        }
                    }
            }
        }
        .sheet(isPresented: $isActionButtonFlowPresented) {
            NavigationStack {
                ActionButtonFlow()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isActionButtonFlowPresented = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Close")
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func activationCard(
        title: String,
        subtitle: String,
        systemImage: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.primaryGradient.opacity(0.8))
                        .frame(width: 52, height: 52)
                        .shadow(color: AppTheme.glow.opacity(0.25), radius: 10, x: 0, y: 6)
                        .opacity(isDisabled ? 0.5 : 1.0)
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isDisabled ? 0.6 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(isDisabled ? .secondary : .primary)
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .opacity(isDisabled ? 0.4 : 1.0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .buttonStyle(.plain)
    }
    
#if canImport(UIKit)
    private func deviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            id.append(String(UnicodeScalar(UInt8(value))))
        }
        return identifier
    }
#endif
}

#Preview {
    ChooseActivationPageView().preferredColorScheme(.dark)
}

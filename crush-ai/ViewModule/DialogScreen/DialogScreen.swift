//
//  DialogScreen.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI
import SwiftData

struct DialogScreen: View {
    @AppStorage("tone") private var currentTone: ToneTypes = .RIZZ
    @AppStorage("replyLanguage") private var replyLanguage: String = "auto"
    @AppStorage("useEmojis") private var useEmojis: Bool = false
    
    var dialog: DialogEntity
    var dialogGroup: DialogGroupEntity
    var defaultImage = "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png"
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    @StateObject private var dialogScreenVm: DialogScreenViewModel
    @State private var selectedChips: Set<String> = []
    @FocusState private var isContextFocused: Bool
    @State private var showPaywall: Bool = false
    
    init(dialog: DialogEntity, dialogGroup: DialogGroupEntity) {
        self.dialog = dialog
        self.dialogGroup = dialogGroup
        let fallbackURL = URL(string: defaultImage)! // This is a constant valid URL
        let currentURL = dialog.image?.localFileURL ?? dialog.image?.remoteHTTPURL ?? fallbackURL
        _dialogScreenVm = StateObject(
            wrappedValue: DialogScreenViewModel(
                dialog: dialog,
                currentImageUrl: currentURL,
                context: dialog.context
            )
        )
    }
    
    var body: some View {
        ZStack {
            backgroundView
            list
        }
        // Тап по пустому фону закрывает клавиатуру
        .contentShape(Rectangle())
//        .onTapGesture { isContextFocused = false }
        .navigationTitle(dialog.title)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            if #available(iOS 26.0, *) {
                ToolbarItem (placement: .bottomBar) {
                    ToneButtonView()
                }
                .sharedBackgroundVisibility(.hidden)
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(placement: .bottomBar)
            }
            if #available(iOS 26.0, *) {
                ToolbarItem (placement: .bottomBar) {
                    PrimaryCTAButton(
                        title: dialogScreenVm.isLoading ? "Getting Reply…" : "Get Reply",
                        isLoading: dialogScreenVm.isLoading
                    ) {
                        guard !dialogScreenVm.isLoading else { return }
                        // Проверка подписки перед выполнением действия
                        if !paywallViewModel.isSubscriptionActive {
                            showPaywall = true
                            return
                        }
                        performGetReply()
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            ToolbarItem {
                SettingsButton(destination: SettingsPlaceholderView())
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }
            ToolbarItem {
                AddNewDialogButton(dialogGroup: dialogGroup)
            }
        }
        .alert("Failed to analyze screenshot", isPresented: $dialogScreenVm.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dialogScreenVm.errorText)
        }
        // На iOS < 26 рисуем свою нижнюю панель, чтобы кнопка заняла всю ширину.
        .safeAreaInset(edge: .bottom) {
            if #available(iOS 26.0, *) {
                // Ничего не добавляем — на iOS 26+ используется Toolbar
                EmptyView()
            } else {
                HStack(spacing: 12) {
                    ToneButtonView()
                    PrimaryCTAButton(
                        title: dialogScreenVm.isLoading ? "Getting Reply…" : "Get Reply",
                        isLoading: dialogScreenVm.isLoading,
                        fullWidth: true
                    ) {
                        guard !dialogScreenVm.isLoading else { return }
                        // Проверка подписки перед выполнением действия
                        if !paywallViewModel.isSubscriptionActive {
                            showPaywall = true
                            return
                        }
                        performGetReply()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.bar) // визуально как тулбар
            }
        }
        // Paywall presentation
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onContinue: {
                    showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        performGetReply()
                    }
                },
                onRestore: {
                    showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        performGetReply()
                    }
                },
                onDismiss: {
                    showPaywall = false
                }
            )
            .preferredColorScheme(.dark)
        }
    }
    
    private func performGetReply() {
        // Синхронизируем введенный контекст перед запросом
        dialog.context = dialogScreenVm.context
        Task {
            await dialogScreenVm.getReply(
                modelContext: modelContext,
                tone: currentTone,
                replyLanguage: replyLanguage,
                useEmojis: useEmojis,
                paymentToken: paywallViewModel.appUserID
            )
        }
    }
    
    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ImageView(image: dialog.image, isLoading: dialogScreenVm.isLoading)
                
                // Context input
                ContextInputCard(
                    text: Binding(
                        get: { dialogScreenVm.context ?? "" },
                        set: { dialogScreenVm.context = $0 }
                    ),
                    isFocused: $isContextFocused
                )
                .padding(.horizontal, 20)
                
                //                Elements
                RepliesList(replies: dialog.replies)
            }
            .padding(.bottom, 50)
        }
        // Тап по прокрутке вне инпута тоже закрывает клавиатуру
//        .simultaneousGesture(TapGesture().onEnded { isContextFocused = false })
    }
    
    private var Elements: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !dialog.elements.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Spacer(minLength: 0) // помогает центрировать при контенте меньше ширины
                        HStack(spacing: 8) {
                            ForEach(dialog.elements, id: \.self) { element in
                                SelectableChip(
                                    title: element,
                                    isSelected: Binding(
                                        get: { selectedChips.contains(element) },
                                        set: { newValue in
                                            if newValue { selectedChips.insert(element) }
                                            else { selectedChips.remove(element) }
                                        }
                                    )
                                )
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity) // чтобы центрирование работало по ширине контейнера
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                }
            } else {
                Text("No elements")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var backgroundView: some View {
        OnboardingBackground
            .opacity(0.5)
            // Тап по фону закрывает клавиатуру
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded { isContextFocused = false })
    }
}

struct ImageView: View {
    var image: ImageEntity?
    var isLoading: Bool
    
    var body: some View {
        if let img = image {
            LargeImageDisplay(isLoading: isLoading, imageEntity: img)
                .padding(.horizontal, 20)
        } else {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
        }
    }
}


struct LargeImageDisplay: View {
    
    var isLoading: Bool = false
    var imageEntity: ImageEntity
    
    private let corner: CGFloat = 24
    
    // Числовое состояние для бесконечного движения «луча»
    @State private var scanY: CGFloat = 0
    
    var body: some View {
        ZStack {
            content
            //                .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(AppTheme.borderPrimaryGradient, lineWidth: 1))
            
            if isLoading {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.black.opacity(0.25))
                    .overlay {
                        ZStack {
                            // Лёгкая сетка как намёк на «анализ»
                            GeometryReader { geo in
                                let spacing: CGFloat = 22
                                Canvas { context, size in
                                    var path = Path()
                                    // Вертикальные линии
                                    var x: CGFloat = 0
                                    while x <= size.width {
                                        path.move(to: CGPoint(x: x, y: 0))
                                        path.addLine(to: CGPoint(x: x, y: size.height))
                                        x += spacing
                                    }
                                    // Горизонтальные линии
                                    var y: CGFloat = 0
                                    while y <= size.height {
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: size.width, y: y))
                                        y += spacing
                                    }
                                    context.stroke(path, with: .color(.white.opacity(0.08)), lineWidth: 0.5)
                                }
                                .blendMode(.plusLighter)
                                .allowsHitTesting(false)
                                
                                // Двигающийся «луч» сканирования — бесконечная линейная анимация
                                let beamHeight = max(40, geo.size.height * 0.18)
                                
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.35),
                                        .white.opacity(0.55),
                                        .white.opacity(0.35),
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: beamHeight)
                                .blur(radius: 6)
                                .mask(
                                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                                        .fill(.white)
                                )
                                .offset(y: scanY)
                                // При изменении размеров (например, поворот) — перезапустим анимацию
                                .id(beamHeight)
                                .onAppear {
                                    // старт над верхней границей
                                    scanY = -beamHeight
                                    withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                                        // финиш ниже нижней границы
                                        scanY = geo.size.height + beamHeight
                                    }
                                }
                            }
                            
                            // Угловые маркеры
                            CornerMarks(cornerRadius: corner)
                                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: 0)
                                .blendMode(.plusLighter)
                            
                            // Центр. индикатор
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.1)
                                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    }
            }
        }
        .contentTransition(.opacity)
    }
    
    // Type-erased to keep the compiler happy across branches
    private var content: some View {
        Group {
            if let url = imageEntity.localFileURL, let img = loadImage(from: url) {
                AnyView(
                    img
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: 450)
                )
            } else if let url = imageEntity.remoteHTTPURL {
                AnyView(
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            AnyView(
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 500)
                            )
                        case .failure:
                            AnyView(placeholder)
                        case .empty:
                            AnyView(
                                ZStack {
                                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                                        .fill(.white.opacity(0.06))
                                    ProgressView()
                                        .tint(.white.opacity(0.85))
                                }
                            )
                        @unknown default:
                            AnyView(placeholder)
                        }
                    } .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                )
            } else {
                AnyView(placeholder)
            }
        }
    }
    
    private var placeholderBase: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.white.opacity(0.06))
    }
    
    private var placeholder: some View {
        ZStack {
            placeholderBase
            Image(systemName: "photo")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(width: 300, height: 500)
    }
    
    private func loadImage(from url: URL) -> Image? {
#if canImport(UIKit)
        if let ui = UIImage(contentsOfFile: url.path) { return Image(uiImage: ui) }
#elseif canImport(AppKit)
        if let ns = NSImage(contentsOf: url) { return Image(nsImage: ns) }
#endif
        return nil
    }
}

// Декоративные угловые маркеры для состояния загрузки
private struct CornerMarks: Shape {
    var cornerRadius: CGFloat
    var inset: CGFloat = 6
    var length: CGFloat = 24
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = cornerRadius
        _ = r // зарезервировано на случай будущей логики, сейчас не влияет на форму
        
        // Top-left
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset + length))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.minX + inset + length, y: rect.minY + inset))
        
        // Top-right
        p.move(to: CGPoint(x: rect.maxX - inset - length, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset + length))
        
        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset - length))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset - length, y: rect.maxY - inset))
        
        // Bottom-left
        p.move(to: CGPoint(x: rect.minX + inset + length, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset - length))
        
        return p
    }
}

// MARK: - Context Input Card


#Preview {
    
    @Previewable var paywallviewModel = PaywallViewModel(isPreview: true)
    
    let image = ImageEntity(id: "id", remoteUrl: "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png")
    let dialog = DialogEntity(id: "id2", userId: "u", title: "Test name", elements: ["opener", "test", "profile", "opener", "test", "profile"])
    
    let reply1 = ReplyEntity(id: "2", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .RIZZ)
    let reply2 = ReplyEntity(id: "3", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .NSFW)
    let reply3 = ReplyEntity(id: "4", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .FLIRT)
    let reply4 = ReplyEntity(id: "5", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .ROMANTIC)
    
    dialog.image = image
    
    dialog.replies = [reply1, reply2, reply3, reply4]
    
    let dialogGroup = DialogGroupEntity(id: "asd", userId: "i", title: "Test")
    
    dialogGroup.cover = image
    dialogGroup.dialogs = [dialog]
    
    return DialogScreen(dialog: dialog, dialogGroup: dialogGroup)
        .preferredColorScheme(.dark)
        .environmentObject(paywallviewModel)
}

//
//  DialogScreen.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import StoreKit

struct DialogScreen: View {
    @AppStorage("tone") private var currentTone: ToneTypes = .RIZZ
    @AppStorage("replyLanguage") private var replyLanguage: String = "auto"
    @AppStorage("useEmojis") private var useEmojis: Bool = false
    
    var dialog: DialogEntity
    var dialogGroup: DialogGroupEntity
    var defaultImage = "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png"
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    @Environment(\.requestReview) private var requestReview
    
    @StateObject private var dialogScreenVm: DialogScreenViewModel
    @State private var selectedChips: Set<String> = []
    @FocusState private var isContextFocused: Bool
    @State private var showPaywall: Bool = false
    
    // Новый стейт для показа GiftView и передачи месячного пакета
    @State private var showGift: Bool = false
    @State private var giftMonthlyPackage: Package? = nil
    
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
            
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.65)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    ToneButtonView()
                    PrimaryCTAButton(
                        title: dialogScreenVm.isLoading ? "Getting Reply…" : "Get Reply",
                        isLoading: dialogScreenVm.isLoading,
                        fullWidth: true
                    ) {
                        guard !dialogScreenVm.isLoading else { return }
                        if !paywallViewModel.isSubscriptionActive {
                            showPaywall = true
                            return
                        }
                        performGetReply()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        // Тап по пустому фону закрывает клавиатуру
        .contentShape(Rectangle())
//        .onTapGesture { isContextFocused = false }
        .navigationTitle(dialog.title)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem {
                SettingsButton(destination: SettingsPlaceholderView())
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
        // Paywall presentation
        .sheet(isPresented: $showPaywall) {
            PaywallView(
                onContinue: {
                    // Покупка могла пройти — закрываем пейвол
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
                    // Пользователь закрыл пейвол — покажем GiftView
                    showPaywall = false
                    // Если по UX GiftView нужно показывать всегда на dismiss — просто включаем ниже
                    showGift = true
                },
//                onDismissWithMonthly: { monthly in
//                    // Сохраняем месячный пакет, полученный из PaywallView
//                    giftMonthlyPackage = monthly
//                }
            )
            .preferredColorScheme(.dark)
        }
        // GiftView presentation сразу после закрытия пейвола
//        .sheet(isPresented: $showGift) {
//            GiftView(injectedMonthlyPackage: giftMonthlyPackage)
//                .preferredColorScheme(.dark)
//        }
        // Покрываем кейс свайпа по sheet: когда showPaywall стал false, а подписки нет — показываем GiftView
//        .onChange(of: showPaywall) { isPresented in
//            if isPresented == false && !paywallViewModel.isSubscriptionActive {
//                showGift = true
//            }
//        }
    }
    
    private func performGetReply() {
        // Синхронизируем введенный контекст перед запросом
        dialog.context = dialogScreenVm.context
        
        // Запоминаем количество ответов до запроса
        let initialCount = dialog.replies.count
        
        Task {
            await dialogScreenVm.getReply(
                modelContext: modelContext,
                tone: currentTone,
                replyLanguage: replyLanguage,
                useEmojis: useEmojis,
                paymentToken: paywallViewModel.appUserID
            )
            
            // Проверяем успешность: нет показанной ошибки и появились новые ответы
            let hasNewReplies = dialog.replies.count > initialCount
            if !dialogScreenVm.showingError && hasNewReplies {
                // Запрос системного промпта оценки
                requestReview()
            }
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
            .padding(.bottom, 120)
        }
        // Включаем именованное пространство для параллакса
        .coordinateSpace(name: "dialogScroll")
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
    
    // Базовая высота области изображения (синхронизирована с maxHeight внутри LargeImageDisplay)
    private let baseHeight: CGFloat = 450
    
    var body: some View {
        GeometryReader { geo in
            // Позиция контейнера относительно скролла
            let minY = geo.frame(in: .named("dialogScroll")).minY
            let pullDown = max(0, minY)          // тянем вниз
            let scrollUp = min(0, minY)          // скроллим вверх (отрицательное)
            
            // Лёгкий параллакс при прокрутке вверх (картинка «отстаёт»)
            let parallaxOffset = -scrollUp * 0.25
            
            // Небольшой скейл при вытягивании вниз
            let scale = 1.0 + (pullDown / 600.0)
            
            // Плавное затухание при прокрутке вверх, минимум 0.2
            let fade = max(0.2, 1.0 + (scrollUp / 600.0))
            
            ZStack {
                if let img = image {
                    LargeImageDisplay(isLoading: isLoading, imageEntity: img)
                        .scaleEffect(scale, anchor: .center)
                        .offset(y: parallaxOffset)
                        .opacity(fade)
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .scaleEffect(scale, anchor: .center)
                        .offset(y: parallaxOffset)
                        .opacity(fade)
                }
            }
            .padding(.horizontal, 20)
        }
        // GeometryReader требует зафиксированной высоты
        .frame(height: baseHeight)
    }
}


#Preview {
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
}

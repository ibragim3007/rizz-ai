//
//  DialogScreen.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI
import SwiftData

struct DialogScreen: View {
    var dialog: DialogEntity
    var defaultImage = "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png"
    
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var dialogScreenVm: DialogScreenViewModel
    @State private var selectedChips: Set<String> = []
    
    init(dialog: DialogEntity) {
        self.dialog = dialog
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
        .navigationTitle(dialog.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem (placement: .bottomBar) {
                ToneButtonView()
            }
            ToolbarSpacer(.fixed)
            ToolbarItem (placement: .bottomBar) {
                GlassButton(
                    action: {
                        guard !dialogScreenVm.isLoading else { return }
                        Task { await dialogScreenVm.getReply(modelContext: modelContext) }
                    },
                    text: dialogScreenVm.isLoading ? "Getting Reply…" : "Get Reply",
                    isLoading: dialogScreenVm.isLoading,
                )

            }
            ToolbarItem {
                SettingsButton(destination: SettingsPlaceholderView())
            }
        }
        .alert("Failed to analyze screenshot", isPresented: $dialogScreenVm.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dialogScreenVm.errorText)
        }
    }
    
    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ImageView(image: dialog.image)
//                Elements
                RepliesList(replies: dialog.replies)
            }
            .padding(.bottom, 20)
        }
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
        OnboardingBackground.opacity(0.5)
    }
}

struct ImageView: View {
    var image: ImageEntity?

    var body: some View {
        if let img = image {
            LargeImageDisplay(imageEntity: img)
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
    
    var body: some View {
        ZStack {
            content
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
//                .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(AppTheme.borderPrimaryGradient, lineWidth: 1))
            
            if isLoading {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.black.opacity(0.25))
                    .overlay {
                        ProgressView()
                            .tint(.white)
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
                        .frame(maxWidth: .infinity, maxHeight: 500)
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
                    }
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


#Preview {
    let image = ImageEntity(id: "id", remoteUrl: "https://cdsassets.apple.com/live/7WUAS350/images/ios/ios-26-iphone-16-pro-take-a-screenshot-options.png")
    let dialog = DialogEntity(id: "id2", userId: "u", title: "Test name", elements: ["opener", "test", "profile", "opener", "test", "profile"])
    
    let reply1 = ReplyEntity(id: "2", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .RIZZ)
    let reply2 = ReplyEntity(id: "3", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .NSFW)
    let reply3 = ReplyEntity(id: "4", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .FLIRT)
    let reply4 = ReplyEntity(id: "5", content: "psum is that it has a more-or-less normal distribution", createdAt: Date.now, tone: .ROMANTIC)
    
    dialog.image = image
    
    dialog.replies = [reply1, reply2, reply3, reply4]
    
    return DialogScreen(dialog: dialog).preferredColorScheme(.dark)
}


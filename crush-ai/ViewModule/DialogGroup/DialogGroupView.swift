//
//  DialogGroup.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI
import _PhotosUI_SwiftUI
import SwiftData

struct DialogGroupView: View {
    
    var dialogGroup: DialogGroupEntity
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var homeVm = HomeViewModel()
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            backgroundView
            listView
        }
        .navigationTitle(dialogGroup.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem { SettingsButton(destination: SettingsPlaceholderView()) }
            ToolbarItem (placement: .bottomBar) {
                PrimaryCTAButton(
                    title: "Add Screenshot",
                    height: 60,
                    font: .system(size: 20, weight: .semibold, design: .rounded),
                    fullWidth: true
                ) {
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    showPhotoPicker = true
                }
            }.sharedBackgroundVisibility(.hidden)
        }
        // Программная навигация к новосозданному диалогу
        .navigationDestination(isPresented: $homeVm.shouldNavigateToDialog) {
            if let dialog = homeVm.navigateDialog {
                DialogScreen(dialog: dialog)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            // Поздняя инъекция контекста для VM
            if homeVm.modelContext == nil {
                homeVm.modelContext = modelContext
            }
        }
        // Фото-пикер
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await homeVm.handlePickedPhoto(item, for: dialogGroup)
                // Сбрасываем выбор, чтобы можно было выбрать то же фото снова при желании
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
    }
    
    private var backgroundView: some View {
        OnboardingBackground.opacity(0.5)
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sections, id: \.title) { section in
                    if !section.items.isEmpty {
                        // Lightweight "section" to reduce generic complexity
                        VStack(alignment: .leading, spacing: 16) {
                            Text(section.title)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                ForEach(section.items, id: \.id) { dialog in
                                    NavigationLink(destination: DialogScreen(dialog: dialog)) {
                                        DialogCardRow(dialog: dialog)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Row

private struct DialogCardRow: View {
    let dialog: DialogEntity
    
    private let corner: CGFloat = 28
    private let thumbSize: CGFloat = 84
    
    var body: some View {
        HStack(spacing: 16) {
            thumbnail
                .frame(width: thumbSize, height: thumbSize)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(dialog.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                
                Text(dateSubtitle(for: dialog.updatedAt))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(glassBackground)
        .padding(.horizontal, 20)
    }
    
    // MARK: Thumbnail
    
    @ViewBuilder
    private var thumbnail: some View {
        if let image = dialog.image {
            PreviewImageView(imageEntity: image)
        } else if let cover = dialog.group?.cover {
            PreviewImageView(imageEntity: cover)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
        }
    }
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(AppTheme.primaryDark.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(AppTheme.borderPrimaryGradient, lineWidth: 1)
            )
//            .shadow(color: AppTheme.glow.opacity(0.12), radius: 14, x: 0, y: 8)
//            .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
    }
    
    // MARK: Date formatting
    
    private func dateSubtitle(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = .current
        df.setLocalizedDateFormatFromTemplate("EEEE, HH:mm") // Friday, 16:53
        return df.string(from: date)
    }
}

// MARK: - Image loader from ImageEntity

private struct PreviewImageView: View {
    let imageEntity: ImageEntity
    private let corner: CGFloat = 18
    
    var body: some View {
        Group {
            if let url = imageEntity.localFileURL, let img = loadImage(from: url) {
                img.resizable().scaledToFill()
            } else if let url = imageEntity.remoteHTTPURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: placeholder
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: corner, style: .continuous)
                                .fill(.white.opacity(0.06))
                            ProgressView()
                                .tint(.white.opacity(0.85))
                        }
                    @unknown default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: corner, style: .continuous).stroke(AppTheme.borderPrimaryGradient, lineWidth: 1))
    }
    
    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(.white.opacity(0.06))
            Image(systemName: "photo")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
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

// MARK: - Sectioning

private struct DialogSection {
    let title: String
    let items: [DialogEntity]
}

private extension DialogGroupView {
    var sections: [DialogSection] {
        let items = dialogGroup.dialogs.sorted { $0.updatedAt > $1.updatedAt }
        return makeSections(from: items)
    }
    
    func makeSections(from dialogs: [DialogEntity]) -> [DialogSection] {
        var today: [DialogEntity] = []
        var yesterday: [DialogEntity] = []
        var last7: [DialogEntity] = []
        var older: [DialogEntity] = []
        
        let cal = Calendar.current
        let now = Date()
        
        for d in dialogs {
            let date = d.updatedAt
            if cal.isDateInToday(date) {
                today.append(d)
            } else if cal.isDateInYesterday(date) {
                yesterday.append(d)
            } else if let diff = cal.dateComponents([.day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: now)).day, diff < 7 {
                last7.append(d)
            } else {
                older.append(d)
            }
        }
        
        var result: [DialogSection] = []
        if !today.isEmpty { result.append(.init(title: NSLocalizedString("Today", comment: ""), items: today)) }
        if !yesterday.isEmpty { result.append(.init(title: NSLocalizedString("Yesterday", comment: ""), items: yesterday)) }
        if !last7.isEmpty { result.append(.init(title: NSLocalizedString("Previous 7 Days", comment: ""), items: last7)) }
        if !older.isEmpty {
            // Можно сгруппировать по месяцам, но для простоты — один блок
            result.append(.init(title: NSLocalizedString("Older", comment: ""), items: older))
        }
        return result
    }
}

#Preview {
    // Пример превью с фиктивными данными
    let cover = ImageEntity(id: "img1", localUrl: "girl-3", remoteUrl: "girl-3")
    let d1 = DialogEntity(id: "1", userId: "u", title: "Home screen opener prep", createdAt: .now.addingTimeInterval(-3600), updatedAt: .now.addingTimeInterval(-3600))
    let d2 = DialogEntity(id: "2", userId: "u", title: "Home screen, no chat", createdAt: .now.addingTimeInterval(-7200), updatedAt: .now.addingTimeInterval(-7200))
    let d3 = DialogEntity(id: "3", userId: "u", title: "Group chat banter about AI", createdAt: .now.addingTimeInterval(-60*60*26), updatedAt: .now.addingTimeInterval(-60*60*26))
    let d4 = DialogEntity(id: "4", userId: "u", title: "Group chat technical banter", createdAt: .now.addingTimeInterval(-60*60*28), updatedAt: .now.addingTimeInterval(-60*60*28))
    let group = DialogGroupEntity(id: "g", userId: "u", title: "crush ai")
    d1.image = cover
    group.dialogs = [d1, d2, d3, d4]
    group.cover = cover
    
    return NavigationStack {
        DialogGroupView(dialogGroup: group)
            .preferredColorScheme(.dark)
    }
}

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
                DialogScreen(dialog: dialog, dialogGroup: dialogGroup)
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
                                    NavigationLink(destination: DialogScreen(dialog: dialog, dialogGroup: dialogGroup)) {
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

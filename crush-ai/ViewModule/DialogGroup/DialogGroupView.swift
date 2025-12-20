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
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    @StateObject private var homeVm = HomeViewModel()
    @StateObject private var groupVm = DialogGroupViewModel()
    
    // Delete-all confirmation state (like Home.swift)
    @State private var showDeleteAllConfirm = false
    @State private var pendingDeleteItems: [DialogEntity] = []
    @State private var pendingDeleteTitle: String = ""
    
    // Programmatic navigation for tapping a row (to avoid system chevron)
    @State private var tappedDialog: DialogEntity?
    @State private var showDialogScreen = false
    
    var body: some View {
        ZStack {
            backgroundView
            listView
            
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.35)
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
                PrimaryCTAButton(
                    title: "Add Screenshot",
                    height: 60,
                    font: .system(size: 20, weight: .semibold, design: .rounded),
                    fullWidth: true
                ) {
                    homeVm.uploadScreenshot()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle(dialogGroup.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem { SettingsButton(destination: SettingsPlaceholderView()) }
        }
        // Программная навигация к новосозданному диалогу (из добавления фото)
        .navigationDestination(isPresented: $homeVm.shouldNavigateToDialog) {
            if let dialog = homeVm.navigateDialog {
                DialogScreen(dialog: dialog, dialogGroup: dialogGroup)
            } else {
                EmptyView()
            }
        }
        // Программная навигация по тапу на строку (без системной стрелки)
        .navigationDestination(isPresented: $showDialogScreen) {
            if let d = tappedDialog {
                DialogScreen(dialog: d, dialogGroup: dialogGroup)
            } else {
                EmptyView()
            }
        }
        .onAppear {
            // Late injection of dependencies
            if homeVm.modelContext == nil {
                homeVm.modelContext = modelContext
            }
            // Важно: пробрасываем менеджер подписки в VM
            if homeVm.paywallViewModel == nil {
                homeVm.paywallViewModel = paywallViewModel
            }
            if groupVm.modelContext == nil {
                groupVm.modelContext = modelContext
            }
        }
        // Фото-пикер (используем состояние из homeVm)
        .photosPicker(
            isPresented: $homeVm.showPhotoPicker,
            selection: $homeVm.selectedPhotoItem,
            matching: .images
        )
        .onChange(of: homeVm.selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await homeVm.handlePickedPhoto(item, for: dialogGroup)
                // Сбрасываем выбор, чтобы можно было выбрать то же фото снова при желании
                await MainActor.run {
                    homeVm.selectedPhotoItem = nil
                }
            }
        }
        // Delete-all confirmation (section)
        .alert(
            String(format: NSLocalizedString("Delete all in “%@”?", comment: "Delete all confirmation title"), pendingDeleteTitle),
            isPresented: $showDeleteAllConfirm
        ) {
            Button(NSLocalizedString("Delete All", comment: "Confirm delete all"), role: .destructive) {
                withAnimation(.snappy(duration: 0.28)) {
                    groupVm.deleteAll(pendingDeleteItems, in: dialogGroup)
                }
                // Reset state
                pendingDeleteItems.removeAll()
                pendingDeleteTitle = ""
            }
            Button(NSLocalizedString("Cancel", comment: "Cancel"), role: .cancel) {
                pendingDeleteItems.removeAll()
                pendingDeleteTitle = ""
            }
        } message: {
            Text(NSLocalizedString("This action cannot be undone.", comment: "Delete all warning"))
        }
        // Paywall sheet (контролируется VM)
        .sheet(isPresented: $homeVm.showPaywall) {
            PaywallView(
                onContinue: {
                    // Закрываем paywall и повторяем сценарий добавления
                    homeVm.showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        homeVm.uploadScreenshot()
                    }
                },
                onRestore: {
                    homeVm.showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        homeVm.uploadScreenshot()
                    }
                },
                onDismiss: {
                    homeVm.showPaywall = false
                }
            )
            .preferredColorScheme(.dark)
        }
    }
    
    private var backgroundView: some View {
        OnboardingBackground.opacity(0.3)
    }
    
    private var listView: some View {
        List {
            ForEach(sections, id: \.title) { section in
                if !section.items.isEmpty {
                    Section {
                        ForEach(section.items, id: \.id) { dialog in
                            // Вместо NavigationLink — обычная кнопка без системной стрелки
                            Button {
                                tappedDialog = dialog
                                showDialogScreen = true
                            } label: {
                                DialogCardRow(dialog: dialog)
                            }
                            .buttonStyle(.plain)
                            // Swipe-to-delete
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    groupVm.requestDelete(dialog)
                                    groupVm.confirmDelete(in: dialogGroup)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            // Optional: context menu alternative
                            .contextMenu {
                                Button(role: .destructive) {
                                    groupVm.requestDelete(dialog)
                                    groupVm.confirmDelete(in: dialogGroup)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            // Снимаем системные инкрусты, даем строке самой управлять отступами/фоном
                            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    } header: {
                        // Header with delete-all button (right-aligned)
                        HStack {
                            Text(section.title)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                            
                            Spacer()
                            
                            Button {
                                pendingDeleteItems = section.items
                                pendingDeleteTitle = section.title
                                showDeleteAllConfirm = true
                            } label: {
                                Label {
                                    Text(NSLocalizedString("Delete All", comment: "Delete all in section"))
                                } icon: {
                                    Image(systemName: "trash")
                                }
                            }
                            .buttonStyle(.borderless)
                            .tint(.white.opacity(0.4))
                            .foregroundStyle(.white.opacity(0.4))
                            .font(.footnote)
                            .accessibilityLabel(Text(NSLocalizedString("Delete all in section", comment: "Delete all in section")))
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .scrollIndicators(.hidden)
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
    @Previewable @StateObject var paywallViewModel = PaywallViewModel()
    
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
            .environmentObject(paywallViewModel)
            .preferredColorScheme(.dark)
    }
}

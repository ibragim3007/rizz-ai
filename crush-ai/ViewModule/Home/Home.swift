//
//  Home.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct Home: View {
    @Environment(\.modelContext) private var modelContext
    // Диалоги теперь подтягиваем из SwiftData, чтобы список обновлялся сам
    @Query(sort: \DialogGroupEntity.updatedAt, order: .reverse) private var dialogs: [DialogGroupEntity]
    @StateObject var vmHome = HomeViewModel()
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
    
    // Состояния для "Delete All"
    @State private var showDeleteAllConfirm = false
    @State private var pendingDeleteItems: [DialogGroupEntity] = []
    @State private var pendingDeleteTitle: String = ""
    
    var body: some View {
        ZStack {

            MeshedGradient()
            
            if dialogs.isEmpty {
                EmptyDialogsView()
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
            
            contentList
                .scrollIndicators(.hidden)
                .toolbar {
                    if #available(iOS 26.0, *) {
                        ToolbarItem (placement: .topBarLeading) { Logo() } .sharedBackgroundVisibility(.hidden)
                    } else {
                        ToolbarItem (placement: .topBarLeading) { Logo() }
                    }
                    ToolbarItem { SettingsButton(destination: SettingsPlaceholderView()) }
                    if #available(iOS 26.0, *) {
                        ToolbarItem(placement: .bottomBar) {
                            PrimaryCTAButton(
                                title: "Upload Screenshot",
                                height: 60,
                                font: .system(size: 20, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
                                vmHome.uploadScreenshot()
                            }
                        }
                        .sharedBackgroundVisibility(.hidden)
                    } else {
                        // Fallback on earlier versions
                        ToolbarItem(placement: .bottomBar) {
                            PrimaryCTAButton(
                                title: "Upload Screenshot",
                                height: 60,
                                font: .system(size: 20, weight: .semibold, design: .rounded),
                                fullWidth: true
                            ) {
                                vmHome.uploadScreenshot()
                            }
                        }
                    }
                }
                .navigationTitle("Crush AI")
                .navigationBarTitleDisplayMode(.inline)
        }
        // Презентация PhotosPicker
        .photosPicker(
            isPresented: Binding(get: { vmHome.showPhotoPicker }, set: { vmHome.showPhotoPicker = $0 }),
            selection: Binding(get: { vmHome.selectedPhotoItem }, set: { vmHome.selectedPhotoItem = $0 }),
            matching: .images,
            preferredItemEncoding: .automatic
        )
        // Обработка выбранного элемента
        .onChange(of: vmHome.selectedPhotoItem) { oldItem, newItem in
            guard let item = newItem else { return }
            Task { await vmHome.handlePickedPhoto(item) }
        }
        // Inject dependencies after the view appears
        .onAppear {
            vmHome.modelContext = modelContext
            vmHome.paywallViewModel = paywallViewModel
        }
        // Подтверждение удаления всех элементов секции
        .alert(
            String(format: NSLocalizedString("Delete all in “%@”?", comment: "Delete all confirmation title"), pendingDeleteTitle),
            isPresented: $showDeleteAllConfirm
        ) {
            Button(NSLocalizedString("Delete All", comment: "Confirm delete all"), role: .destructive) {
                withAnimation(.snappy(duration: 0.28)) {
                    // Удаляем все группы в выбранной секции через VM (чтобы почистить файлы изображений)
                    for item in pendingDeleteItems {
                        vmHome.delete(item)
                    }
                }
                // Сброс состояния
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
        // Programmatic navigation using modern API (iOS 16+)
        .navigationDestination(
            isPresented: Binding(
                get: { vmHome.shouldNavigateToDialog },
                set: { vmHome.shouldNavigateToDialog = $0 }
            )
        ) {
            if let dialog = vmHome.navigateDialog, let group = vmHome.navigateDialogGroup {
                DialogScreen(dialog: dialog, dialogGroup: group)
            } else {
                EmptyView()
            }
        }
        // Paywall sheet (controlled by VM)
        .sheet(isPresented: $vmHome.showPaywall) {
            PaywallView(
                onContinue: {
                    // При успешной покупке можно автоматически открыть загрузку
                    vmHome.showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        vmHome.uploadScreenshot()
                    }
                },
                onRestore: {
                    vmHome.showPaywall = false
                    if paywallViewModel.isSubscriptionActive {
                        vmHome.uploadScreenshot()
                    }
                },
                onDismiss: {
                    vmHome.showPaywall = false
                }
            )
            .preferredColorScheme(.dark)
        }
        // Ловим deep link из виджета и открываем загрузку скриншота
        .onOpenURL { url in
            guard url.scheme?.lowercased() == "crushai" else { return }
            // Поддержим оба варианта: crushai://upload_screenshot и crushai:///upload_screenshot
            let host = url.host?.lowercased()
            let path = url.path.lowercased()
            if host == "upload_screenshot" || path == "/upload_screenshot" {
                vmHome.uploadScreenshot()
            }
        }
    }
    
    private var contentList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sections, id: \.title) { section in
                    if !section.items.isEmpty {
                        DialogsSectionView(
                            section: section,
                            columns: columns,
                            onDeleteSingle: { vmHome.delete($0) },
                            onDeleteAllTap: {
                                pendingDeleteItems = section.items
                                pendingDeleteTitle = section.title
                                showDeleteAllConfirm = true
                            },
                            onTogglePin: { vmHome.togglePin($0) }
                        )
                    }
                }
            }
            .padding(.vertical, 30)
        }
    }
}




struct GroupSection {
    let title: String
    let items: [DialogGroupEntity]
}

private extension Home {
    var sections: [GroupSection] {
//        let items = dialogs.sorted { $0.updatedAt > $1.updatedAt }
        return makeSections(from: dialogs)
    }
    
    func makeSections(from groups: [DialogGroupEntity]) -> [GroupSection] {
        // Секция "Pinned"
        let pinnedItems = groups.filter { $0.pinned }.sorted { $0.updatedAt > $1.updatedAt }
        // Остальные — по датам
        let nonPinned = groups.filter { !$0.pinned }
        
        var today: [DialogGroupEntity] = []
        var yesterday: [DialogGroupEntity] = []
        var last7: [DialogGroupEntity] = []
        var older: [DialogGroupEntity] = []
        
        let cal = Calendar.current
        let now = Date()
        
        for g in nonPinned {
            let date = g.updatedAt
            if cal.isDateInToday(date) {
                today.append(g)
            } else if cal.isDateInYesterday(date) {
                yesterday.append(g)
            } else if let diff = cal.dateComponents([.day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: now)).day, diff < 7 {
                last7.append(g)
            } else {
                older.append(g)
            }
        }
        
        var result: [GroupSection] = []
        if !pinnedItems.isEmpty { result.append(.init(title: NSLocalizedString("Pinned", comment: ""), items: pinnedItems)) }
        if !today.isEmpty { result.append(.init(title: NSLocalizedString("Today", comment: ""), items: today)) }
        if !yesterday.isEmpty { result.append(.init(title: NSLocalizedString("Yesterday", comment: ""), items: yesterday)) }
        if !last7.isEmpty { result.append(.init(title: NSLocalizedString("Previous 7 Days", comment: ""), items: last7)) }
        if !older.isEmpty { result.append(.init(title: NSLocalizedString("Older", comment: ""), items: older)) }
        return result
    }
}


#Preview {
    Home()
        .preferredColorScheme(.dark)
}


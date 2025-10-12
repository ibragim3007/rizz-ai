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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)

    var body: some View {
        ZStack {
            OnboardingBackground.opacity(0.5)

            if dialogs.isEmpty {
                EmptyDialogsView()
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(sections, id: \.title) { section in
                        if !section.items.isEmpty {
                            Section {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(section.items, id: \.self) { dialogGroup in
                                        NavigationLink(destination: DialogGroupView(dialogGroup: dialogGroup )) {
                                            ScreenShotItem(imageURL: dialogGroup.cover?.localFileURL, title: dialogGroup.title)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 4)
                            } header: {
                                Text(section.title)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 30)
            }
            .scrollIndicators(.hidden)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .toolbar {
                ToolbarItem (placement: .topBarLeading) { Logo() }.sharedBackgroundVisibility(.hidden)
                ToolbarItem { SettingsButton(destination: SettingsPlaceholderView()) }
                ToolbarItem(placement: .bottomBar) {
                    PrimaryCTAButton(
                        title: "Upload Screenshot",
                        height: 60,
                        font: .system(size: 20, weight: .semibold, design: .rounded),
                        fullWidth: true
                    ) {
                        vmHome.uploadScreenshot()
                    }
                    .padding(.horizontal, 10)
                }
                .sharedBackgroundVisibility(.hidden)
            }
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
        // Inject ModelContext after the view appears
        .onAppear {
            vmHome.modelContext = modelContext
        }
    }
}



// Заглушка настроек


// Пустое состояние диалогов
private struct EmptyDialogsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Пока пусто")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
            Text("Загрузите скриншот, чтобы начать новый диалог.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Sectioning (по аналогии с DialogGroupView)

private struct GroupSection {
    let title: String
    let items: [DialogGroupEntity]
}

private extension Home {
    var sections: [GroupSection] {
        let items = dialogs.sorted { $0.updatedAt > $1.updatedAt }
        return makeSections(from: items)
    }

    func makeSections(from groups: [DialogGroupEntity]) -> [GroupSection] {
        var today: [DialogGroupEntity] = []
        var yesterday: [DialogGroupEntity] = []
        var last7: [DialogGroupEntity] = []
        var older: [DialogGroupEntity] = []

        let cal = Calendar.current
        let now = Date()

        for g in groups {
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


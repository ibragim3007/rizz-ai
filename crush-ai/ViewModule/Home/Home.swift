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
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(dialogs, id: \.self) { dialogGroup in
                        NavigationLink(destination: DialogGroupView(dialogGroup: dialogGroup )) {
                            ScreenShotItem(imageURL: dialogGroup.cover?.localFileURL, title: dialogGroup.title)
                        }
                    }
                }
                .padding(.horizontal, 20)
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

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}

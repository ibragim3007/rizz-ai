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
    @Query(sort: \DialogEntity.updatedAt, order: .reverse) private var dialogs: [DialogEntity]
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
                    ForEach(dialogs, id: \.self) { dialog in
                        ScreenShotItem(imageURL: dialog.image?.localFileURL, title: dialog.title)
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
                ToolbarItem { SettingsButton(showSettings: vmHome.showSettings) }
                ToolbarItem(placement: .bottomBar) {
                    PrimaryCTAButton(
                        title: "Upload Screenshot",
                        height: 60,
                        font: .system(size: 20, weight: .semibold, design: .rounded),
                        fullWidth: true
                    ) {
                        uploadScreenshot()
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
        .onChange(of: vmHome.selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task { await handlePickedPhoto(item) }
        }
    }

    // MARK: - Upload Screenshot Flow

    private func uploadScreenshot() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        vmHome.showPhotoPicker = true
    }

    @MainActor
    private func handlePickedPhoto(_ item: PhotosPickerItem) async {
        do {
            // Загружаем данные изображения
            guard let data = try await item.loadTransferable(type: Data.self) else { return }

            // Сохраняем в файловую систему (Documents)
            let fileURL = try saveImageDataToDocuments(data: data, suggestedName: await suggestedFilename(from: item))

            // Создаем ImageEntity
            let imageEntity = ImageEntity(id: UUID().uuidString, localUrl: fileURL.path, remoteUrl: nil, createdAt: .now)

            // Создаем DialogEntity (подставим простой userId; замените на свой источник при наличии)
            let dialog = DialogEntity(
                id: UUID().uuidString,
                userId: "local-user",
                title: "Unnamed",
                context: nil,
                summary: nil,
                elements: [],
                createdAt: .now,
                updatedAt: .now
            )
            dialog.image = imageEntity

            // Сохраняем в SwiftData
            modelContext.insert(imageEntity)
            modelContext.insert(dialog)
            try modelContext.save()

        } catch {
            print("Failed to handle picked photo: \(error)")
        }
    }

    private func saveImageDataToDocuments(data: Data, suggestedName: String?) throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let baseName = (suggestedName?.isEmpty == false ? suggestedName! : UUID().uuidString)
        // По умолчанию используем .jpg
        var targetURL = docs.appendingPathComponent(baseName).appendingPathExtension("jpg")

        // Если файл существует — добавляем суффикс
        var counter = 1
        while fm.fileExists(atPath: targetURL.path) {
            targetURL = docs.appendingPathComponent("\(baseName)-\(counter)").appendingPathExtension("jpg")
            counter += 1
        }

        try data.write(to: targetURL, options: .atomic)
        return targetURL
    }

    private func suggestedFilename(from item: PhotosPickerItem) async -> String? {
        await item.itemIdentifier?.split(separator: "/").last.map(String.init)
    }
}



// Заглушка настроек
private struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Settings") {
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Settings")
        }
    }
}

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

//
//  DialogViewModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import Foundation
import Combine
import SwiftUI
import _PhotosUI_SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var showSettings = false
    @Published var showPhotoPicker = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    // Navigation intent to DialogScreen
    @Published var navigateDialog: DialogEntity?
    @Published var shouldNavigateToDialog: Bool = false
    
    // Allow late injection from the View
    var modelContext: ModelContext?
    
    init() {}
    
    convenience init(modelContext: ModelContext) {
        self.init()
        self.modelContext = modelContext
    }
    
    func handlePickedPhoto(_ item: PhotosPickerItem) async {
        do {
            // Ensure we have a context
            guard let ctx = modelContext else { return }
            
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
            
            let dialogGroup = DialogGroupEntity(
                id: UUID().uuidString, userId: "local-user", title: "Unnamed"
            )
            
            dialog.image = imageEntity
            dialogGroup.dialogs.append(dialog)
            dialogGroup.cover = imageEntity

            // Сохраняем в SwiftData
            withAnimation(.snappy(duration: 0.32)) {
                ctx.insert(imageEntity)
                ctx.insert(dialog)
                ctx.insert(dialogGroup)
                do {
                    try ctx.save()
                } catch {
                    print("Failed to save after insert: \(error)")
                }
            }
            
            // Trigger navigation to DialogScreen for the just-created dialog
            self.navigateDialog = dialog
            self.shouldNavigateToDialog = true

        } catch {
            print("Failed to handle picked photo: \(error)")
        }
    }
    
    
    // MARK: - Upload Screenshot Flow

    func uploadScreenshot() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        showPhotoPicker = true
    }

    // MARK: - Deletion

    func delete(_ group: DialogGroupEntity) {
        guard let ctx = modelContext else { return }
        
        // Удаляем локальные файлы и сущности изображений, чтобы не оставлять сироты
        // 1) Cover
        if let cover = group.cover {
            deleteImageFileIfExists(from: cover)
            ctx.delete(cover)
        }
        // 2) Изображения у диалогов внутри группы
        for dialog in group.dialogs {
            if let image = dialog.image {
                deleteImageFileIfExists(from: image)
                ctx.delete(image)
            }
        }
        
        // Удаляем саму группу (каскадно удалит replies через dialogs; images у dialogs уже почистили вручную)
        withAnimation(.snappy(duration: 0.28)) {
            ctx.delete(group)
            do {
                try ctx.save()
            } catch {
                print("Failed to delete DialogGroupEntity: \(error)")
            }
        }
    }

    private func deleteImageFileIfExists(from image: ImageEntity) {
        guard let path = image.localUrl else { return }
        let url = URL(fileURLWithPath: path)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to remove image file at \(url.path): \(error)")
        }
    }

    // MARK: - File saving helpers

    func saveImageDataToDocuments(data: Data, suggestedName: String?) throws -> URL {
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


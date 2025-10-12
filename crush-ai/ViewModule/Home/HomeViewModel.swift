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
            
            dialogGroup.dialogs.append(dialog)
            dialogGroup.cover = imageEntity

            // Сохраняем в SwiftData
            ctx.insert(imageEntity)
            ctx.insert(dialog)
            ctx.insert(dialogGroup)
            try ctx.save()

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


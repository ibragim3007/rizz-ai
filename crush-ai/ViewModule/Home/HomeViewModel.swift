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
import ImageIO

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var showSettings = false
    @Published var showPhotoPicker = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    
    // Paywall presentation controlled from VM
    @Published var showPaywall: Bool = false
    
    // Navigation intent to DialogScreen
    @Published var navigateDialog: DialogEntity?
    @Published var navigateDialogGroup: DialogGroupEntity?
    @Published var shouldNavigateToDialog: Bool = false
    
    // Allow late injection from the View
    var modelContext: ModelContext?
    
    // Subscription state (inject from View via EnvironmentObject)
    var paywallViewModel: PaywallViewModel?
    
    init() {}
    
    convenience init(modelContext: ModelContext) {
        self.init()
        self.modelContext = modelContext
    }
    
    func handlePickedPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let ctx = modelContext else { return }
            
            // Загружаем исходные байты
            guard let originalData = try await item.loadTransferable(type: Data.self) else { return }

            // Перекодируем и даунскейлим (уменьшает "Documents" кратно)
            let jpegData = Self.reencodeImageToJPEG(originalData,
                                                    maxDimension: 1024,
                                                    quality: 0.6) ?? originalData

            // Сохраняем в файловую систему (Documents)
            let fileURL = try saveImageDataToDocuments(
                data: jpegData,
                suggestedName: await suggestedFilename(from: item),
                forceExtension: "jpg"
            )

            // Сохраняем в модель ТОЛЬКО имя файла (relative)
            let imageEntity = ImageEntity(
                id: UUID().uuidString,
                localUrl: fileURL.lastPathComponent,
                remoteUrl: nil,
                createdAt: .now
            )

            // Создаем DialogEntity
            let dialog = DialogEntity(
                id: UUID().uuidString,
                userId: "local-user",
                title: "",
                context: nil,
                summary: nil,
                elements: [],
                createdAt: .now,
                updatedAt: .now
            )
            
            let dialogGroup = DialogGroupEntity(
                id: UUID().uuidString, userId: "local-user", title: ""
            )
            
            dialog.image = imageEntity
            dialog.group = dialogGroup
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
            self.navigateDialogGroup = dialogGroup
            self.shouldNavigateToDialog = true

        } catch {
            print("Failed to handle picked photo: \(error)")
        }
    }
    
    /// Создает новый диалог в уже существующей группе, добавляет фото, обновляет cover и дату обновления группы.
    func handlePickedPhoto(_ item: PhotosPickerItem, for group: DialogGroupEntity) async {
        do {
            guard let ctx = modelContext else { return }
            
            // 1) Загрузка и перекодирование изображения
            guard let originalData = try await item.loadTransferable(type: Data.self) else { return }
            let jpegData = Self.reencodeImageToJPEG(originalData,
                                                    maxDimension: 1024,
                                                    quality: 0.6) ?? originalData
            
            // 2) Сохранение файла в Documents
            let fileURL = try saveImageDataToDocuments(
                data: jpegData,
                suggestedName: await suggestedFilename(from: item),
                forceExtension: "jpg"
            )
            
            // 3) Создание сущностей
            let now = Date()
            let imageEntity = ImageEntity(
                id: UUID().uuidString,
                localUrl: fileURL.lastPathComponent, // сохраняем только имя файла
                remoteUrl: nil,
                createdAt: now
            )
            
            let dialog = DialogEntity(
                id: UUID().uuidString,
                userId: "local-user",
                title: "",
                context: nil,
                summary: nil,
                elements: [],
                createdAt: now,
                updatedAt: now
            )
            
            // 4) Установка связей
            dialog.image = imageEntity
            dialog.group = group
            group.dialogs.append(dialog)
            
            // Обновляем обложку и дату обновления группы
            group.cover = imageEntity
            group.updatedAt = now
            
            // 5) Сохранение
            withAnimation(.snappy(duration: 0.32)) {
                ctx.insert(imageEntity)
                ctx.insert(dialog)
                // Группа уже существует в контексте, повторно вставлять не нужно
                do {
                    try ctx.save()
                } catch {
                    print("Failed to save new dialog into existing group: \(error)")
                }
            }
            
            // 6) Навигация к новому диалогу
            self.navigateDialog = dialog
            self.navigateDialogGroup = group
            self.shouldNavigateToDialog = true
            
        } catch {
            print("Failed to handle picked photo for existing group: \(error)")
        }
    }
    
    
    // MARK: - Upload Screenshot Flow

    func uploadScreenshot() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        // Проверка подписки централизована в VM
        if let paywall = paywallViewModel, paywall.isSubscriptionActive == false {
            showPaywall = true
            return
        }
        // Нет Paywall или подписка активна — открываем пикер
        showPhotoPicker = true
    }

    // MARK: - Pin / Unpin

    func togglePin(_ group: DialogGroupEntity) {
        guard let ctx = modelContext else { return }
        group.pinned.toggle()
        do {
            try ctx.save()
        } catch {
            print("Failed to save pin toggle: \(error)")
        }
    }

    // MARK: - Deletion

    func delete(_ group: DialogGroupEntity) {
        guard let ctx = modelContext else { return }
        
        // Собираем все уникальные ImageEntity, чтобы не удалить один и тот же объект дважды
        var imagesToDelete = [String: ImageEntity]()
        if let cover = group.cover {
            imagesToDelete[cover.id] = cover
        }
        for dialog in group.dialogs {
            if let image = dialog.image {
                imagesToDelete[image.id] = image
            }
        }
        
        // Сначала удаляем файлы и сущности изображений (каждую ровно один раз)
        for (_, image) in imagesToDelete {
            deleteImageFileIfExists(from: image)
            ctx.delete(image)
        }
        
        // Затем удаляем саму группу (каскадно удалит replies через dialogs; ссылки на images уже обнулены удалением)
        withAnimation(.snappy(duration: 0.28)) {
            ctx.delete(group)
            do {
                try ctx.save()
            } catch {
                print("Failed to delete DialogGroupEntity: \(error)")
            }
        }
        
        // На всякий случай — убрать возможных сирот (если были сложные сценарии привязок)
        Task { await cleanupOrphanImages() }
    }

    private func deleteImageFileIfExists(from image: ImageEntity) {
        guard let url = image.localFileURL else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Failed to remove image file at \(url.path): \(error)")
        }
    }

    // MARK: - File saving helpers

    func saveImageDataToDocuments(data: Data, suggestedName: String?, forceExtension: String? = nil) throws -> URL {
        let fm = FileManager.default
        let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let baseName = (suggestedName?.isEmpty == false ? suggestedName! : UUID().uuidString)
        let ext = forceExtension ?? "jpg"
        var targetURL = docs.appendingPathComponent(baseName).appendingPathExtension(ext)

        // Если файл существует — добавляем суффикс
        var counter = 1
        while fm.fileExists(atPath: targetURL.path) {
            targetURL = docs.appendingPathComponent("\(baseName)-\(counter)").appendingPathExtension(ext)
            counter += 1
        }

        try data.write(to: targetURL, options: .atomic)
        return targetURL
    }

    private func suggestedFilename(from item: PhotosPickerItem) async -> String? {
        item.itemIdentifier?.split(separator: "/").last.map(String.init)
    }
    
    // MARK: - Image recompression
    
    /// Перекодирует входные байты изображения в JPEG c даунскейлом через ImageIO.
    /// Гарантирует, что длинная сторона будет <= maxDimension (в пикселях).
    static func reencodeImageToJPEG(_ data: Data, maxDimension: CGFloat = 2200, quality: CGFloat = 0.75) -> Data? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension),
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let thumb = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary) else { return nil }
        
        #if canImport(UIKit)
        let ui = UIImage(cgImage: thumb)
        return ui.jpegData(compressionQuality: quality)
        #elseif canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: thumb)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
        #else
        return nil
        #endif
    }
    
    // MARK: - Orphan cleanup
    
    /// Удаляет ImageEntity, на которые никто не ссылается, вместе с их файлами.
    func cleanupOrphanImages() async {
        guard let ctx = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<ImageEntity>()
            let images = try ctx.fetch(descriptor)
            var removed = 0
            for img in images {
                if img.dialog == nil && img.dialogGroup == nil {
                    deleteImageFileIfExists(from: img)
                    ctx.delete(img)
                    removed += 1
                }
            }
            if removed > 0 {
                try ctx.save()
            }
        } catch {
            print("Failed to cleanup orphan images: \(error)")
        }
    }
}


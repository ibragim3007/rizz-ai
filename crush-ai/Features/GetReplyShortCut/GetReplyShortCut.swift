//
//  GetReplyShortCut.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/23/25.
//

import AppIntents
import Foundation
import UIKit
import UniformTypeIdentifiers
import SwiftData
import RevenueCat
import UserNotifications

@available(iOS 18.0, *)
struct GetReplyIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Reply"
    
    @Parameter(
        title: .init(stringLiteral: "Choose a image"),
        description: "Memory",
        supportedContentTypes: [UTType.image],
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var imageFile: IntentFile
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Прочитаем системные настройки
        let defaults = UserDefaults.standard
        
        // Проверка «повтор в течение 10 сек?»
        let now = Date().timeIntervalSince1970
        let lastTs = defaults.double(forKey: "lastScreenshotAt")
        let isWithin10s = (lastTs > 0) && ((now - lastTs) < 10.0)
        
        if isWithin10s {
            // Возвращаем следующий готовый ответ из последнего диалога — без генерации новых
            let container = await crush_aiApp.makeContainer()
            let ctx = ModelContext(container)
            
            // Пытаемся найти диалог по сохранённому ID, иначе берем самый последний
            let dialog: DialogEntity?
            if let savedID = defaults.string(forKey: "cyclingDialogID"),
               let found = try? fetchDialog(byID: savedID, in: ctx) {
                dialog = found
            } else {
                dialog = try? fetchLatestDialog(in: ctx)
                if let d = dialog {
                    defaults.set(d.id, forKey: "cyclingDialogID")
                    defaults.set(0, forKey: "cyclingReplyIndex")
                }
            }
            
            guard let dialog else {
                let msg = "No previous replies found. Take a new screenshot to generate replies."
                await postLocalNotification(title: "No replies", body: msg)
                return .result(value: msg)
            }
            
            let ordered = dialog.replies.sorted { $0.createdAt < $1.createdAt }
            let currentIndex = defaults.integer(forKey: "cyclingReplyIndex")
            
            guard !ordered.isEmpty else {
                let msg = "No replies available yet. Take a new screenshot to generate replies."
                await postLocalNotification(title: "No replies", body: msg)
                return .result(value: msg)
            }
            
            if currentIndex < ordered.count {
                let replyText = ordered[currentIndex].content
                defaults.set(currentIndex + 1, forKey: "cyclingReplyIndex")
                
                await postLocalNotification(
                    title: "Your reply",
                    body: replyText
                )
                return .result(value: replyText)
            } else {
                let msg = "All replies have been used. Take a new screenshot to generate more."
                await postLocalNotification(title: "Need a new screenshot", body: msg)
                return .result(value: msg)
            }
        }
        
        // Дальше — обычный путь: новый скриншот => сохраним изображение, создадим сущности и, если есть подписка, сгенерируем ответ
        // 1) Проверим тип содержимого
        if let type = imageFile.type, !type.conforms(to: UTType.image) {
            throw NSError(domain: "GetReplyIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: "The file is not an image"])
        }
        
        // 2) Получаем байты безопасно (предпочитаем imageFile.data)
        var originalData: Data = imageFile.data
        
        // Fallback: если data пустые, пробуем security-scoped URL
        if originalData.isEmpty, let url = imageFile.fileURL {
            var didAccess = false
            if url.startAccessingSecurityScopedResource() {
                didAccess = true
            }
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            originalData = (try? Data(contentsOf: url)) ?? Data()
        }
        guard !originalData.isEmpty else {
            throw NSError(domain: "GetReplyIntent", code: 2, userInfo: [NSLocalizedDescriptionKey: "Пустые данные изображения."])
        }
        
        // 3) Перекодируем и даунскейлим, чтобы экономить место (как в HomeViewModel)
        let jpegData = await HomeViewModel.reencodeImageToJPEG(originalData, maxDimension: 1024, quality: 0.6) ?? originalData
        
        // 4) Сохраняем файл в Documents (общий helper из HomeViewModel)
        let savedURL = try await HomeViewModel.saveImageDataToDocuments(
            data: jpegData,
            suggestedName: imageFile.filename,
            forceExtension: "jpg"
        )
        
        // 5) Создаём сущности SwiftData и сохраняем их (и получаем контекст)
        let (_, dialog, ctx) = try await saveEntities(imageFilename: savedURL.lastPathComponent)
        
        // 6) Если есть активная подписка — запускаем getReply
        let isSubscribed = await checkSubscriptionActive()

        if isSubscribed {
            // Прочитаем пользовательские настройки (совпадают с AppStorage ключами)
            let defaults = UserDefaults.standard
            let language = defaults.string(forKey: "replyLanguage") ?? "auto"
            let useEmojis = defaults.object(forKey: "useEmojis") as? Bool ?? false
            let toneRaw = defaults.string(forKey: "tone") ?? ToneTypes.RIZZ.rawValue
            let tone = ToneTypes(rawValue: toneRaw) ?? .RIZZ
            
            // payment token — как в PaywallViewModel
            let paymentToken = Purchases.shared.appUserID
            
            // Создаём VM и дергаем getReply
            let vm = await DialogScreenViewModel(
                dialog: dialog,
                currentImageUrl: savedURL,
                context: dialog.context
            )
            await vm.getReply(
                modelContext: ctx,
                tone: tone,
                replyLanguage: language,
                useEmojis: useEmojis,
                paymentToken: paymentToken
            )
            
            // После получения ответа сервером заголовки могли обновиться.
            // Если title группы совпал с уже существующей группой — переносим диалог в первую такую группу и удаляем новую.
            await mergeGroupIfNeeded(for: dialog, in: ctx)
            
            // Берем первый ответ по порядку и показываем в уведомлении + кладем в буфер обмена
            let ordered = dialog.replies.sorted { $0.createdAt < $1.createdAt }
            let replyText = ordered.first?.content ?? "Reply requested and will appear in the app."

            // Сохраняем состояние циклирования: начинаем с индекса 1 (первый уже отдали)
            let nowTs = Date().timeIntervalSince1970
            defaults.set(nowTs, forKey: "lastScreenshotAt")
            defaults.set(dialog.id, forKey: "cyclingDialogID")
            let nextIndex = ordered.isEmpty ? 0 : 1
            defaults.set(nextIndex, forKey: "cyclingReplyIndex")

            // Notify user
            await postLocalNotification(
                title: "Your reply is ready",
                body: replyText
            )
            
            return .result(value: replyText)
        } else {
            // Нет подписки — уведомим пользователя (не включаем в цикл)
            await postLocalNotification(
                title: "Saved",
                body: "Image saved. Subscribe to generate replies."
            )
        }
        
        // 7) Ответ для Shortcuts
        return .result(value: "Image saved. Subscribe to generate replies.")
    }
    
    // MARK: - Helpers
    
    private func checkSubscriptionActive() async -> Bool {
        await withCheckedContinuation { continuation in
            Purchases.shared.getCustomerInfo { info, _ in
                let active = info?.entitlements.all["Full Access"]?.isActive == true
                continuation.resume(returning: active)
            }
        }
    }
    
    private func imageSizeString(from data: Data) throws -> String {
        guard let img = UIImage(data: data) else { return "unknown" }
        return "\(Int(img.size.width))x\(Int(img.size.height))"
    }
    
    // Local notification helpers
    private func ensureNotificationAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                return granted
            } catch {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
    
    private func postLocalNotification(title: String, body: String) async {
        guard await ensureNotificationAuthorization() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Fire immediately (0.1s)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "GetReplyIntent-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            // Silently ignore in intent context
        }
    }
    
    // Создаём и сохраняем ImageEntity, DialogEntity, DialogGroupEntity в SwiftData
    private func saveEntities(imageFilename: String) async throws -> (DialogGroupEntity, DialogEntity, ModelContext) {
        // Поднимаем контейнер с той же схемой, что и в приложении
        let container = await crush_aiApp.makeContainer()
        let ctx = ModelContext(container)
        
        let now = Date()
        let imageEntity = ImageEntity(
            id: UUID().uuidString,
            localUrl: imageFilename,
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
        
        // Попробуем найти последний диалог и, если он свежий (< 10 сек), использовать его группу
        var groupToUse: DialogGroupEntity?
        if let latest = try? fetchLatestDialog(in: ctx) {
            let delta = now.timeIntervalSince(latest.createdAt)
            if delta < 10, let existingGroup = latest.group {
                groupToUse = existingGroup
            }
        }
        
        if let group = groupToUse {
            // Добавляем в существующую группу
            dialog.image = imageEntity
            dialog.group = group
            group.dialogs.append(dialog)
            // Обновим обложку и updatedAt, как при добавлении в существующую группу в UI
            group.cover = imageEntity
            group.updatedAt = now
            
            ctx.insert(imageEntity)
            ctx.insert(dialog)
            try ctx.save()
            
            return (group, dialog, ctx)
        } else {
            // Создаем новую группу
            let group = DialogGroupEntity(
                id: UUID().uuidString,
                userId: "local-user",
                title: "" // можно позже проставить после анализа
            )
            
            dialog.image = imageEntity
            dialog.group = group
            group.dialogs.append(dialog)
            group.cover = imageEntity
            group.updatedAt = now
            
            ctx.insert(imageEntity)
            ctx.insert(dialog)
            ctx.insert(group)
            try ctx.save()
            
            return (group, dialog, ctx)
        }
    }
    
    // MARK: - Fetch helpers (SwiftData)
    private func fetchDialog(byID id: String, in ctx: ModelContext) throws -> DialogEntity? {
        var desc = FetchDescriptor<DialogEntity>(
            predicate: #Predicate { $0.id == id }
        )
        desc.fetchLimit = 1
        let result = try ctx.fetch(desc)
        return result.first
    }
    
    private func fetchLatestDialog(in ctx: ModelContext) throws -> DialogEntity? {
        var desc = FetchDescriptor<DialogEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        desc.fetchLimit = 1
        let result = try ctx.fetch(desc)
        return result.first
    }
    
    // MARK: - Merge by title
    
    /// Если у текущей группы заголовок совпадает с уже существующей группой,
    /// переносит диалог в первую такую группу и удаляет временную.
    private func mergeGroupIfNeeded(for dialog: DialogEntity, in ctx: ModelContext) async {
        guard let currentGroup = dialog.group else { return }
        let title = currentGroup.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let currentGroupID = currentGroup.id
        
        // Найдём первую (самую раннюю) существующую группу с таким же title, исключая текущую
        var fetch = FetchDescriptor<DialogGroupEntity>(
            predicate: #Predicate { group in
                group.title == title && group.id != currentGroupID
            },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        fetch.fetchLimit = 1
        
        do {
            let matches = try ctx.fetch(fetch)
            guard let target = matches.first else { return }
            
            // Удаляем диалог из временной группы
            if let idx = currentGroup.dialogs.firstIndex(where: { $0.id == dialog.id }) {
                currentGroup.dialogs.remove(at: idx)
            }
            // Переназначаем связь
            dialog.group = target
            target.dialogs.append(dialog)
            target.updatedAt = Date()
            if target.cover == nil {
                // Если у целевой группы нет обложки — можно поставить текущую
                target.cover = dialog.image ?? currentGroup.cover
            }
            
            // ВАЖНО: чтобы каскадное удаление cover не удалило ImageEntity,
            // который используется как dialog.image, обнулим cover перед удалением группы.
            currentGroup.cover = nil
            
            // Удаляем временную группу
            ctx.delete(currentGroup)
            
            try ctx.save()
        } catch {
            // В контексте Intents лучше молча не падать
            // Можно залогировать в отладке, если нужно
        }
    }
}

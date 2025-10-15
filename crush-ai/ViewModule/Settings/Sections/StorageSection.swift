//
//  StorageSection.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI
import SwiftData

struct StorageSection: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appActions) private var appActions
    
    @State private var storeSizeBytes: Int64 = 0
    @State private var imagesSizeBytes: Int64 = 0
    @State private var isComputing: Bool = false
    @State private var showConfirm: Bool = false
    @State private var isWiping: Bool = false
    @State private var errorText: String?
    @State private var showError: Bool = false
    
    private var totalSizeBytes: Int64 { storeSizeBytes + imagesSizeBytes }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("SwiftData store")
                Text(byteCountString(storeSizeBytes))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Images")
                Text(byteCountString(imagesSizeBytes))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            showConfirm = true
        } label: {
            if isWiping {
                HStack {
                    ProgressView().tint(.white)
                    Text("Cleaning…")
                }
            } else if isComputing {
                HStack {
                    ProgressView().tint(.white)
                    Text("Calculating…")
                }
            } else {
                Text("Clear All Data (\(byteCountString(totalSizeBytes)))")
            }
        }
        .disabled(isComputing || isWiping)
        .tint(.red)
        .buttonStyle(.borderedProminent)
        .accessibilityLabel("Clear all data")
        .accessibilityHint("Deletes all dialogs, replies and images")
        .alert("Clear all data?", isPresented: $showConfirm) {
            Button("Delete", role: .destructive) {
                Task { await wipeAll() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove all dialogs, replies and images from this device. This action cannot be undone.")
        }
        .task {
            await recomputeSizes()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText ?? "Unknown error")
        }
    }
    
    
    private func byteCountString(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter.string(fromByteCount: bytes)
    }
    
    private func swiftDataStoreURLs() -> [URL] {
        // Берём все конфигурации контейнера и добавляем связанные WAL/SHM
        let configs = modelContext.container.configurations
        var urls: [URL] = []
        for cfg in configs {
            let baseURL = cfg.url
            urls.append(baseURL)
            urls.append(URL(fileURLWithPath: baseURL.path + "-wal"))
            urls.append(URL(fileURLWithPath: baseURL.path + "-shm"))
        }
        return urls
    }
    
    private func fileSize(at url: URL) -> Int64 {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return 0 }
        do {
            let attrs = try fm.attributesOfItem(atPath: url.path)
            return (attrs[.size] as? NSNumber)?.int64Value ?? 0
        } catch {
            return 0
        }
    }
    
    private func recomputeSizes() async {
        await MainActor.run { isComputing = true }
        defer { Task { await MainActor.run { isComputing = false } } }
        
        // 1) Размер стора SwiftData
        let storeURLs = swiftDataStoreURLs()
        let storeBytes = storeURLs.reduce(Int64(0)) { partial, url in
            partial + fileSize(at: url)
        }
        
        // 2) Размер всех локальных изображений из ImageEntity
        var imagesBytes: Int64 = 0
        do {
            let images = try modelContext.fetch(FetchDescriptor<ImageEntity>())
            for img in images {
                if let url = img.localFileURL {
                    imagesBytes += fileSize(at: url)
                }
            }
        } catch {
            // Игнорируем ошибку подсчёта, но показываем алёрт
            await MainActor.run {
                errorText = "Failed to scan images: \(error.localizedDescription)"
                showError = true
            }
        }
        
        await MainActor.run {
            storeSizeBytes = storeBytes
            imagesSizeBytes = imagesBytes
        }
    }
    
    private func wipeAll() async {
        await MainActor.run { isWiping = true }
        defer {
            Task { @MainActor in
                isWiping = false
                #if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                #endif
            }
        }
        
        // 1) Удаляем файлы изображений
        do {
            let images = try modelContext.fetch(FetchDescriptor<ImageEntity>())
            for image in images {
                if let url = image.localFileURL, FileManager.default.fileExists(atPath: url.path) {
                    do { try FileManager.default.removeItem(at: url) }
                    catch { /* пропускаем отдельные ошибки удаления */ }
                }
            }
        } catch {
            await MainActor.run {
                errorText = "Failed to list images: \(error.localizedDescription)"
                showError = true
            }
        }
        
        // 2) Удаляем сущности из SwiftData
        do {
            // Удаляем группами, каскад сотрёт replies у dialogs.
            let groups = try modelContext.fetch(FetchDescriptor<DialogGroupEntity>())
            for g in groups { modelContext.delete(g) }
            
            // На всякий случай удалим оставшиеся Dialog/Reply (если не все охватились каскадом)
            let dialogs = try modelContext.fetch(FetchDescriptor<DialogEntity>())
            for d in dialogs { modelContext.delete(d) }
            let replies = try modelContext.fetch(FetchDescriptor<ReplyEntity>())
            for r in replies { modelContext.delete(r) }
            
            // И отдельно — все ImageEntity (deleteRule .nullify — каскад их не затронет)
            let images = try modelContext.fetch(FetchDescriptor<ImageEntity>())
            for i in images { modelContext.delete(i) }
            
            try modelContext.save()
        } catch {
            await MainActor.run {
                errorText = "Failed to clear database: \(error.localizedDescription)"
                showError = true
            }
        }
        
        // 3) Полный reset стора: закрыть, удалить файлы .sqlite/-wal/-shm, пересоздать контейнер
        await appActions.resetStore()
        
        // 4) Пересчитываем размеры после очистки
        await recomputeSizes()
    }
    
}
    
    


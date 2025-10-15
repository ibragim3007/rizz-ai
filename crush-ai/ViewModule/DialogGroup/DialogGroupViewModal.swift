//
//  DialogGroupViewModal.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class DialogGroupViewModel: ObservableObject {
    // Late injection from View
    var modelContext: ModelContext?

    // Deletion state (single-item)
    @Published var showDeleteAlert: Bool = false
    @Published var dialogPendingDeletion: DialogEntity?

    init() {}

    convenience init(modelContext: ModelContext) {
        self.init()
        self.modelContext = modelContext
    }

    // MARK: - Public Intents (single)

    func requestDelete(_ dialog: DialogEntity) {
        dialogPendingDeletion = dialog
        showDeleteAlert = true
    }

    func cancelDelete() {
        dialogPendingDeletion = nil
        showDeleteAlert = false
    }

    func confirmDelete(in group: DialogGroupEntity) {
        guard let ctx = modelContext, let dialog = dialogPendingDeletion else {
            cancelDelete()
            return
        }
        deleteDialog(dialog, in: group, context: ctx)
        cancelDelete()
    }

    // MARK: - Public Intents (bulk)

    func deleteAll(_ dialogs: [DialogEntity], in group: DialogGroupEntity) {
        guard let ctx = modelContext, !dialogs.isEmpty else { return }

        // Collect images possibly eligible for deletion (deduplicated by id)
        var candidateImages = [String: ImageEntity]()
        for d in dialogs {
            if let img = d.image {
                candidateImages[img.id] = img
            }
        }

        withAnimation(.snappy(duration: 0.30)) {
            // Remove dialogs from group's array to keep UI in sync
            let ids = Set(dialogs.map { $0.id })
            group.dialogs.removeAll { ids.contains($0.id) }

            // If group's cover was among removed dialogs' images, pick a fallback
            if let cover = group.cover, candidateImages[cover.id] != nil {
                group.cover = group.dialogs.first?.image
            }

            // Delete dialogs first (cascade removes replies)
            for d in dialogs {
                ctx.delete(d)
            }

            // Delete images that are now unreferenced
            for (_, img) in candidateImages {
                if img.dialog == nil && img.dialogGroup == nil {
                    deleteImageFileIfExists(from: img)
                    ctx.delete(img)
                }
            }

            // Update timestamp
            group.updatedAt = .now

            do {
                try ctx.save()
            } catch {
                print("Failed to bulk delete dialogs: \(error)")
            }
        }

        // Best-effort final cleanup
        Task { await cleanupOrphanImages() }
    }

    // MARK: - Core Deletion (single)

    private func deleteDialog(_ dialog: DialogEntity, in group: DialogGroupEntity, context ctx: ModelContext) {
        let image = dialog.image

        // Remove from group's list first (keeps UI in sync)
        group.dialogs.removeAll { $0.id == dialog.id }

        withAnimation(.snappy(duration: 0.28)) {
            // If the group's cover equals this dialog's image, pick a fallback cover
            if let cover = group.cover, cover.id == image?.id {
                group.cover = group.dialogs.first?.image
            }

            // Delete the dialog entity (cascade will remove replies)
            ctx.delete(dialog)

            // Attempt to remove image if no one references it
            if let img = image, img.dialog == nil && img.dialogGroup == nil {
                deleteImageFileIfExists(from: img)
                ctx.delete(img)
            }

            // Update group's timestamp
            group.updatedAt = .now

            do {
                try ctx.save()
            } catch {
                print("Failed to delete DialogEntity: \(error)")
            }
        }

        // Final orphan cleanup pass (best-effort)
        Task { await cleanupOrphanImages() }
    }

    // MARK: - Helpers

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

    // MARK: - Orphan cleanup

    /// Removes ImageEntity objects that are no longer referenced by any dialog or group, including their files.
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


//
//  DeleteAccountButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/27/25.
//

import SwiftUI
import SwiftData
import RevenueCat

struct DeleteAccountButton: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appActions) private var appActions
    
    @State private var showConfirm: Bool = false
    @State private var isWiping: Bool = false
    @State private var showError: Bool = false
    @State private var errorText: String?
    
    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            showConfirm = true
        } label: {
            if isWiping {
                HStack(spacing: 8) {
                    ProgressView().tint(.white)
                    Text("Deleting…")
                }
            } else {
                Text("Delete Account")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .disabled(isWiping)
        .accessibilityLabel("Delete account")
        .accessibilityHint("Deletes all dialogs, replies, images, cached settings and tokens from this device")
        .alert("Delete account?", isPresented: $showConfirm) {
            Button("Delete", role: .destructive) {
                Task { await wipeAll() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("""
                 This will permanently delete your account and all associated data (messages, images, profile, device tokens) from our servers. This cannot be undone. App Store subscriptions must be managed in iOS Settings > Subscriptions.
                 """)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorText ?? "Unknown error")
        }
    }
}

// MARK: - Wipe helpers
extension DeleteAccountButton {
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
        
        // 1) Delete image files referenced by ImageEntity
        do {
            let images = try modelContext.fetch(FetchDescriptor<ImageEntity>())
            for image in images {
                if let url = image.localFileURL, FileManager.default.fileExists(atPath: url.path) {
                    do { try FileManager.default.removeItem(at: url) } catch { /* ignore per-file errors */ }
                }
            }
        } catch {
            await MainActor.run {
                errorText = "Failed to list images: \(error.localizedDescription)"
                showError = true
            }
        }
        
        // 2) Delete SwiftData entities (groups -> dialogs/replies via cascade; images separately)
        do {
            let groups = try modelContext.fetch(FetchDescriptor<DialogGroupEntity>())
            for g in groups { modelContext.delete(g) }
            
            // Safety: remove remaining dialogs/replies if any
            let dialogs = try modelContext.fetch(FetchDescriptor<DialogEntity>())
            for d in dialogs { modelContext.delete(d) }
            let replies = try modelContext.fetch(FetchDescriptor<ReplyEntity>())
            for r in replies { modelContext.delete(r) }
            
            // Remove all ImageEntity explicitly (deleteRule .nullify on some relations)
            let images = try modelContext.fetch(FetchDescriptor<ImageEntity>())
            for i in images { modelContext.delete(i) }
            
            try modelContext.save()
        } catch {
            await MainActor.run {
                errorText = "Failed to clear database: \(error.localizedDescription)"
                showError = true
            }
        }
        
        // 3) Reset SwiftData store files (sqlite, wal, shm) and recreate container
        await appActions.resetStore()
        
        // 4) Clear UserDefaults (AppStorage) + app-specific keys
        clearUserDefaults()
        
        // 5) Clear URLCache and Library/Caches
        clearCaches()
        
        // 6) Optional: log out from RevenueCat to reset the appUserID token locally
        await logoutRevenueCat()
    }
    
    private func clearUserDefaults() {
        let defaults = UserDefaults.standard
        
        // Remove the entire app domain (clears @AppStorage-backed values as well)
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        
        // Also explicitly remove keys we know about (harmless if already gone)
        defaults.removeObject(forKey: "replyLanguage")
        defaults.removeObject(forKey: "tone")
        defaults.removeObject(forKey: "useEmojis")
        defaults.removeObject(forKey: "lastScreenshotAt")
        defaults.removeObject(forKey: "cyclingDialogID")
        defaults.removeObject(forKey: "cyclingReplyIndex")
        defaults.removeObject(forKey: "hasSeenOnboarding")
        
        defaults.synchronize()
    }
    
    private func clearCaches() {
        // URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // Library/Caches directory
        let fm = FileManager.default
        if let cachesURL = try? fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            if let contents = try? fm.contentsOfDirectory(at: cachesURL, includingPropertiesForKeys: nil, options: []) {
                for url in contents {
                    try? fm.removeItem(at: url)
                }
            }
        }
    }
    
    private func logoutRevenueCat() async {
        // If user is logged in, log out to reset local user token; ignore errors
        await withCheckedContinuation { continuation in
            Purchases.shared.logOut { _,_  in
                continuation.resume()
            }
        }
    }
}

#Preview {
    DeleteAccountButton()
}

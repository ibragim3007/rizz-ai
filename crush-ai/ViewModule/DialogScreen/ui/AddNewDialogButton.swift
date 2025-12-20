//
//  AddNewDialogButton.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/14/25.
//

import SwiftUI
import _PhotosUI_SwiftUI
import SwiftData

struct AddNewDialogButton: View {
    
    // Target group to add the new dialog into
    var dialogGroup: DialogGroupEntity
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var homeVm = HomeViewModel()
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            showPhotoPicker = true
        }) {
            Image(systemName: "plus.viewfinder")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.fontMain.opacity(0.8))
        }
        .buttonStyle(.plain)
        // Late inject context into VM
        .onAppear {
            if homeVm.modelContext == nil {
                homeVm.modelContext = modelContext
            }
        }
        // Photos picker presentation
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        // Handle selected photo -> create dialog in this group
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await homeVm.handlePickedPhoto(item, for: dialogGroup)
                // Allow re-selecting the same photo again
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
        // Programmatic navigation to the newly created dialog
        .navigationDestination(isPresented: $homeVm.shouldNavigateToDialog) {
            if let dialog = homeVm.navigateDialog {
                DialogScreen(dialog: dialog, dialogGroup: dialogGroup)
            } else {
                EmptyView()
            }
        }
    }
}

//
//  DialogGroupItemView 2.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI

struct DialogGroupItemView: View {
    let dialogGroup: DialogGroupEntity
    let onDelete: () -> Void
    let onTogglePin: () -> Void
    
    var body: some View {
        NavigationLink(destination: DialogGroupView(dialogGroup: dialogGroup)) {
            ScreenShotItem(imageURL: dialogGroup.cover?.localFileURL, title: dialogGroup.title)
                .contentTransition(.opacity)
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)),
                                        removal: .opacity.combined(with: .scale(scale: 0.9))))
        }
        .contextMenu {
            // Pin / Unpin
            Button(action: {
                withAnimation(.snappy(duration: 0.22)) {
                    onTogglePin()
                }
            }) {
                if dialogGroup.pinned {
                    Label(NSLocalizedString("Unpin", comment: "Unpin group"), systemImage: "pin.slash")
                } else {
                    Label(NSLocalizedString("Pin", comment: "Pin group"), systemImage: "pin.fill")
                }
            }
            // Delete
            Button(role: .destructive, action: onDelete) {
                
                let isThereTitle = !dialogGroup.title.isEmpty
                let deleteText = isThereTitle ? "Delete" + " - " + dialogGroup.title : "Delete"
                
                let commentText = isThereTitle ? "This will delete the item: " + dialogGroup.title : "This will delete the item without a title."
                
                Label(NSLocalizedString(deleteText, comment: commentText), systemImage: "trash")
            }
        }
        .preferredColorScheme(.dark)
    }
}

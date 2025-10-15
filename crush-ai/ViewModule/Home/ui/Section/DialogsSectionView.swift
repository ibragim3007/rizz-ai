//
//  DialogsSectionView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI

struct DialogsSectionView: View {
    let section: GroupSection
    let columns: [GridItem]
    let onDeleteSingle: (DialogGroupEntity) -> Void
    let onDeleteAllTap: () -> Void
    let onTogglePin: (DialogGroupEntity) -> Void
    
    var body: some View {
        Section {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(section.items, id: \.id) { dialogGroup in
                    DialogGroupItemView(
                        dialogGroup: dialogGroup,
                        onDelete: {
                            withAnimation(.snappy(duration: 0.28)) {
                                onDeleteSingle(dialogGroup)
                            }
                        },
                        onTogglePin: { onTogglePin(dialogGroup) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            // Анимируем только изменения набора ID внутри секции
            .animation(.snappy(duration: 0.32), value: section.items.map(\.id))
        } header: {
            SectionHeader(section: section, deleteAllAction: onDeleteAllTap)
        }
    }
}

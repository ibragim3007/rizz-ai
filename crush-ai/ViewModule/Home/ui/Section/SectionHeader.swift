//
//  SectionHeader.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/12/25.
//

import SwiftUI

struct SectionHeader: View {
    
    
    var section: GroupSection
    var deleteAllAction: () -> Void
    
    
    var body: some View {
        HStack {
            Text(section.title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            Button {
                deleteAllAction()
            } label: {
                Label {
                    Text(NSLocalizedString("Delete All", comment: "Delete all in section"))
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .buttonStyle(.borderless)
            .tint(.white.opacity(0.4))
            .foregroundStyle(.white.opacity(0.4))
            .font(.footnote)
            .accessibilityLabel(Text(NSLocalizedString("Delete all in section", comment: "Delete all in section")))
        }
        .padding(.horizontal, 20)
    }
    
    
}

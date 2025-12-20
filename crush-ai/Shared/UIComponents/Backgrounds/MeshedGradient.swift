//
//  MeshedGradient.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import SwiftUI

public struct MeshedGradient: View {
    
    public var body: some View {
        if #available(iOS 18.0, *) {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                AppTheme.primary.opacity(0.15), .white, .white,
                .white, AppTheme.primary.opacity(0.10), AppTheme.primary.opacity(0.15),
                AppTheme.primary.opacity(0.1), .white, AppTheme.primary.opacity(0.1)
            ]).ignoresSafeArea()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    MeshedGradient()
}

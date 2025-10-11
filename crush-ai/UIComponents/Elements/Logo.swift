//
//  Logo.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        Image("app-icon")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .cornerRadius(50)
            .overlay {
                RoundedRectangle(cornerRadius: 50, style: .circular)
                    .stroke(AppTheme.primary.opacity(0.5), lineWidth: 1)
            }
    }
}

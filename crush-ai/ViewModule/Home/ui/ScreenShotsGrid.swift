//
//  ScreenShotsGrid.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct ScreenShotsGrid: View {
    let index: Int
    let id: String
    let imagePath: String?
    let title: String?
    
    init(
        index: Int,
        id: String = UUID().uuidString,
        imagePath: String? = nil,
        title: String?
    ) {
        self.index = index
        self.id = id
        self.imagePath = imagePath
        self.title = title
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let cornerRadius: CGFloat = 16
            
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(alignment: .center) {
                    if let path = imagePath {
                        Image(path)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke( LinearGradient(
                                        colors: [.white.opacity(0.25), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                             lineWidth: 1)
                            }
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.26), .white.opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(alignment: .bottom) {
                    Text(title ?? "Unnamed")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(5)
                        .frame(width: (size.width - 10))
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .offset(y: -4)
                }
                .frame(width: size.width, height: size.height)
        }
        .aspectRatio(0.618, contentMode: .fit)
    }
}


#Preview {
    ScreenShotsGrid(index: 0, imagePath: "sample-screen", title: "Karla from college").preferredColorScheme(.dark)
}

//
//  DialogScreenView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation
import Combine


@MainActor
final class DialogScreenViewModel: ObservableObject {
    @Published var currentImageBase64: String
    @Published var context: String?
    
    init(currentImageBase64: String, context: String? = nil) {
        self.currentImageBase64 = currentImageBase64
        self.context = context
    }

}

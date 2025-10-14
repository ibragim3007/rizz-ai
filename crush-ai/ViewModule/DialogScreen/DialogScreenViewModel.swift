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
    @Published var currentImageUrl: URL
    @Published var context: String?
    
    init(currentImageUrl: URL, context: String? = nil) {
        self.currentImageUrl = currentImageUrl
        self.context = context
        
        let base64 = DialogScreenViewModel.makeBase64(from: currentImageUrl)
    }
    
    func getReply () {
        print("Get reply")
    }
    
    
    static func makeBase64(from url: URL?) -> String {
        guard let url else { return "" }
        do {
            let data = try Data(contentsOf: url)
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

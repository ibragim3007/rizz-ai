//
//  DialogViewModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import Foundation
import Combine
import SwiftUI
import _PhotosUI_SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showSettings = false
    @Published var showPhotoPicker = false
    @Published var selectedPhotoItem: PhotosPickerItem?

}

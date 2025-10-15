//
//  MainView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var vmMain = MainViewModel()

    var body: some View {
        NavigationStack {
            Home()
                .task {
                    await vmMain.loginUser()
                }
        }
    }
}



// Плейсхолдер карточки в сетке

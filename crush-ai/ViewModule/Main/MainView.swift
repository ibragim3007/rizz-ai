//
//  MainView.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/11/25.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var vmMain = MainViewModel()
    @EnvironmentObject private var paywallViewModel: PaywallViewModel
    
    // Пейвол при запуске и при потере подписки
    @State private var showPaywallAtLaunch: Bool = false
    
    var body: some View {
        NavigationStack {
            Home()
                .task {
                    await vmMain.loginUser()
                    
                    if !paywallViewModel.isSubscriptionActive {
                        showPaywallAtLaunch = true
                    }
                }
            // Реагируем на изменения статуса подписки:
            // если подписка активна — закрываем пейвол, если нет — показываем
                .onChange(of: paywallViewModel.isSubscriptionActive) { _, isActive in
                    showPaywallAtLaunch = !isActive
                }
            // Глобальный пейвол при старте/потере подписки
                .fullScreenCover(isPresented: $showPaywallAtLaunch) {
                    PaywallView(
                        onContinue: {
                            // Закрываем, если подписка активировалась
                            if paywallViewModel.isSubscriptionActive {
                                showPaywallAtLaunch = false
                            }
                        },
                        onRestore: {
                            if paywallViewModel.isSubscriptionActive {
                                showPaywallAtLaunch = false
                            }
                        },
                        onDismiss: {
                            // Если пользователь закрыл вручную — оставим как есть.
                            // Можно принудительно держать открытым, если нужно:
                            // showPaywallAtLaunch = !paywallViewModel.isSubscriptionActive
                        }
                    )
                }
        }
    }
}



// Плейсхолдер карточки в сетке


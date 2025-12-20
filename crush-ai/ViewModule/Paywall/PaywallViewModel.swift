//
//  PaywallViewModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/15/25.
//

import Foundation
import SwiftUI
import RevenueCat
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    
    @Published var isSubscriptionActive = false
    @Published var appUserID: String = Purchases.shared.appUserID
    
    init () {
        // Инициализация состояния подписки
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Full Access"]?.isActive == true {
                self.isSubscriptionActive = true
            } else {
                self.isSubscriptionActive = false
            }
        }
        
        // Обновим appUserID (на случай, если SDK обновит его после configure)
        self.appUserID = Purchases.shared.appUserID
    }
    
    init (isPreview: Bool) {
        self.isSubscriptionActive = isPreview
        self.appUserID = "preview_user_id"
    }
    
}


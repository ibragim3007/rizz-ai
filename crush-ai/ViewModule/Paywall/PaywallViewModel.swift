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
    
    
    init () {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Full Access"]?.isActive == true {
                self.isSubscriptionActive = true
            }
        }
    }
    
    init (isPreview: Bool) {
        self.isSubscriptionActive = isPreview
    }
    
    
}

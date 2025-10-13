//
//  MainViewModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//


import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    
    @Published var user: User?
    
    // Повторяю логику для main view
    func loginUser() async {
        do {
            let appToken = await TokenService.shared.getOrCreateAppToken()
            let authRequestBody = AuthRequest(appToken: appToken)
            
            // ВАЖНО: передаём конкретный тип, без as? Encodable
            let authResponse: AuthResponse = try await APIClient.shared.request(
                endpoint: "/auth/login",
                method: .post,
                body: authRequestBody,
                headers: nil
            )
            
            user = authResponse.user
            print("Login successful! " + authResponse.user.id)
        } catch {
            print("Login failed: \(error)")
        }
    }
}

//
//  TokenService.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation

actor TokenService {
    static let shared = TokenService()
    
    private let appTokenKey = "appToken"
    private var cachedAppToken: String?
    
    /// Возвращает appToken пользователя. Если он уже сохранён — вернёт сохранённый.
    /// Иначе сгенерирует новый, сохранит в кэш (UserDefaults) и вернёт.
    func getOrCreateAppToken() -> String {
        if let cached = cachedAppToken {
            return cached
        }
        if let stored = UserDefaults.standard.string(forKey: appTokenKey), !stored.isEmpty {
            cachedAppToken = stored
            return stored
        }
        let newToken = Self.generateToken()
        UserDefaults.standard.set(newToken, forKey: appTokenKey)
        cachedAppToken = newToken
        return newToken
    }
    
    /// Опционально: сброс токена (например, для отладки/выхода из аккаунта).
    func resetAppToken() {
        UserDefaults.standard.removeObject(forKey: appTokenKey)
        cachedAppToken = nil
    }
    
    /// Генерация токена. Можно заменить на другой формат при необходимости.
    private static func generateToken() -> String {
        // Компактный UUID без дефисов (32 символа). Можно оставить обычный UUID().uuidString.
        UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }
}

//
//  UserModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation

struct AuthRequest: Encodable {
    let appToken: String
    // Если бэкенд ждёт другое имя ключа, раскомментируйте CodingKeys и поправьте.
    // private enum CodingKeys: String, CodingKey {
    //     case appToken = "app_token"
    // }
}

struct AuthResponse: Codable {
    let accessToken: String
    let user: User
}

struct User: Codable {
    let id: String
    let appToken: String
    let paymentToken: String?
    let role: Role
    let ip: String?
    let pushToken: String?
    let timeZone: String?
    let deviceLocale: String?
    let answerLocale: String?
    let createdAt: Date
    let updatedAt: Date
    
    
    private enum CodingKeys: String, CodingKey {
        case id, appToken, paymentToken, role, ip, pushToken, timeZone, deviceLocale, answerLocale, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        appToken = try c.decode(String.self, forKey: .appToken)
        paymentToken = try c.decodeIfPresent(String.self, forKey: .paymentToken)
        role = try c.decode(Role.self, forKey: .role)
        ip = try c.decodeIfPresent(String.self, forKey: .ip)
        pushToken = try c.decodeIfPresent(String.self, forKey: .pushToken)
        timeZone = try c.decodeIfPresent(String.self, forKey: .timeZone)
        deviceLocale = try c.decodeIfPresent(String.self, forKey: .deviceLocale)
        answerLocale = try c.decodeIfPresent(String.self, forKey: .answerLocale)
        
        let created = try c.decode(String.self, forKey: .createdAt)
        let updated = try c.decode(String.self, forKey: .updatedAt)
        
        func parseISO8601(_ s: String) -> Date? {
            let f1 = ISO8601DateFormatter()
            f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = f1.date(from: s) { return d }
            let f2 = ISO8601DateFormatter()
            return f2.date(from: s)
        }
        
        guard let cAt = parseISO8601(created),
              let uAt = parseISO8601(updated) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.createdAt, CodingKeys.updatedAt],
                                                    debugDescription: "Invalid ISO8601 dates"))
        }
        createdAt = cAt
        updatedAt = uAt
    }
    
}

struct UpdateUserDto: Encodable {
    // Поля, которые можно обновлять (все опциональные)
    let appToken: String?
    let paymentToken: String?
    let ip: String?
    let pushToken: String?
    let timeZone: String?
    let deviceLocale: String?
    let answerLocale: String?
    
    // Кодируем только непустые значения
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(appToken,     forKey: .appToken)
        try c.encodeIfPresent(paymentToken, forKey: .paymentToken)
        try c.encodeIfPresent(ip,           forKey: .ip)
        try c.encodeIfPresent(pushToken,    forKey: .pushToken)
        try c.encodeIfPresent(timeZone,     forKey: .timeZone)
        try c.encodeIfPresent(deviceLocale, forKey: .deviceLocale)
        try c.encodeIfPresent(answerLocale, forKey: .answerLocale)
    }
    
    private enum CodingKeys: String, CodingKey {
        case appToken, paymentToken, ip, pushToken, timeZone, deviceLocale, answerLocale
    }
}


enum Role: String, Codable {
    case user = "USER"
    case admin = "ADMIN"
}

//
//  UserModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation

struct AuthRequest {
    let appToken: String
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

//
//  Network.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

import Foundation

/// HTTP методы
enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

/// Ошибки сетевого слоя
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Incorrect URL"
        case .requestFailed(let code): return "Failed request (\(code))"
        case .decodingFailed: return "Can't decode answer"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var url: URL? { get }
}

/// Протокол API клиента
protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        query: [String: String]?,
        body: Encodable?,
        headers: [String: String]?
    ) async throws -> T
}

/// Стандартный API клиент
final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private init() {}
    
    /// Базовый URL API сервера (замените на ваш)
    private let baseURL = URL(string: "https://crush-ai-server-production.up.railway.app")!
    
    /// Универсальный generic запрос
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        query: [String: String]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        // Формируем URL
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        if let query = query {
            urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        
        // Формируем запрос
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        // Выполняем запрос
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
            }
            guard (200..<300).contains(http.statusCode) else {
                throw NetworkError.requestFailed(http.statusCode)
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingFailed
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - AnyEncodable (для универсальной передачи body)

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init(_ encodable: Encodable) {
        self._encode = encodable.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}


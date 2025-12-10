//
//  HTTPClient.swift
//  DeveloperHub
//
//  Created by Saurabh on 09/12/25.
//


// Network/HTTPClient.swift
import Foundation

struct HTTPClient {
    enum HTTPError: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            throw HTTPError.invalidStatusCode(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

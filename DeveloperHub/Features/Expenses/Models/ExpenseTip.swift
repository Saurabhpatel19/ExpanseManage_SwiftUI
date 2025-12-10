//
//  ExpenseTip.swift
//  DeveloperHub
//
//  Created by Saurabh on 09/12/25.
//


// Features/Expenses/ExpenseTipsAPI.swift
import Foundation

struct ExpenseTip: Decodable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

struct ExpenseTipsAPI {
    private let client = HTTPClient()

    func fetchTips() async throws -> [ExpenseTip] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=5")!
        return try await client.get(url)
    }
}

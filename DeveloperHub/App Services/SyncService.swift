// Services/SyncService.swift
import Foundation

struct SyncService {
    enum SyncError: Error {
        case failed
    }

    func syncExpenses() async throws {
        // Fake delay for demo
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // You can later add real API logic here
    }
}

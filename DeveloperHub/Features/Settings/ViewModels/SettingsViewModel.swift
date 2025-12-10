// ViewModels/SettingsViewModel.swift
import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isSyncing = false
    @Published var syncStatus: String?

    private let syncService: SyncService

    init(makeSyncService: @MainActor @escaping () -> SyncService = { SyncService() }) {
        self.syncService = makeSyncService()
    }

    func syncNow() async {
        guard !isSyncing else { return }

        isSyncing = true
        syncStatus = "Syncing..."

        do {
            try await syncService.syncExpenses()
            let formatted = Date().formatted(date: .abbreviated, time: .shortened)
            syncStatus = "Last sync: \(formatted)"
        } catch {
            syncStatus = "Sync failed: \(error.localizedDescription)"
        }

        isSyncing = false
    }

    func manualSync() {
        Task {
            await syncNow()
        }
    }
}

//
//  ExpenseTipsViewModel.swift
//  DeveloperHub
//
//  Created by Saurabh on 09/12/25.
//


// Features/Expenses/ExpenseTipsViewModel.swift
import Foundation
import Combine

@MainActor
final class ExpenseTipsViewModel: ObservableObject {

    @Published var tips: [ExpenseTip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api = ExpenseTipsAPI()

    func loadTips() async {
        // if already loading, avoid duplicate
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await api.fetchTips()
            tips = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() {
        Task {
            await loadTips()
        }
    }
}

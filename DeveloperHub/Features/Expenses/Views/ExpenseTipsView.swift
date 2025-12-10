//
//  ExpenseTipsView.swift
//  DeveloperHub
//
//  Created by Saurabh on 09/12/25.
//


// Features/Expenses/ExpenseTipsView.swift
import SwiftUI

struct ExpenseTipsView: View {
    @StateObject private var viewModel = ExpenseTipsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tips.isEmpty {
                    VStack {
                        ProgressView("Loading tips...")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text("Failed to load tips")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Retry") {
                            viewModel.refresh()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.tips.isEmpty {
                    Text("No tips available.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.tips) { tip in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tip.title)
                                .font(.headline)
                            Text(tip.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Expense Tips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.refresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            // 👇 async/await kicks in when view appears
            .task {
                await viewModel.loadTips()
            }
        }
    }
}

#Preview {
    ExpenseTipsView()
}

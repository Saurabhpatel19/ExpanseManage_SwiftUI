// Root/SettingsScreen.swift
import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {

                Section("Sync") {
                    if let status = viewModel.syncStatus {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        viewModel.manualSync()      // 👈 this is fine
                    } label: {
                        HStack {
                            if viewModel.isSyncing {
                                ProgressView()
                            }
                            Text(viewModel.isSyncing ? "Syncing…" : "Sync Now")
                        }
                    }
                    .disabled(viewModel.isSyncing)
                }

                Section("Preferences") {
                    Toggle("Dark Mode", isOn: .constant(false))
                    Toggle("Notifications", isOn: .constant(true))
                }

                Section("About") {
                    Text("Version 1.0.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsScreen()
}

import SwiftUI
import SwiftData

@main
struct DeveloperHubApp: App {

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: ExpenseModel.self)
    }
}

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ExpenseListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Expenses")
                }
            ExpenseAnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analytics")
                }
            SettingsScreen()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: ExpenseModel.self)  // ✅ SwiftData preview
}

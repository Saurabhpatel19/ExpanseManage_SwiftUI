import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome 👋")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This is your Expense Manager home.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeScreen()
}

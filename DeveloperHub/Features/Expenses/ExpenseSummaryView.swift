import SwiftUI

struct ExpenseSummaryView: View {
    let total: Double
    let month: Double
    let today: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Spent")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("₹\(Int(total))")
                .font(.system(size: 32, weight: .bold))

            HStack {
                VStack(alignment: .leading) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("₹\(Int(month))")
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("₹\(Int(today))")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.08))
        )
    }
}

#Preview {
    ExpenseSummaryView(total: 3569, month: 3569, today: 420)
}

import SwiftUI
import SwiftData
import Charts

struct ExpenseAnalyticsView: View {
    @Query(sort: \ExpenseModel.date, order: .forward)
    private var expenses: [ExpenseModel]

    @State private var selectedMode: AnalyticsMode = .daily
    @State private var selectedPeriod: MonthFilterOption = .thisMonth

    // MARK: - Filtered base data

    private var filteredExpenses: [ExpenseModel] {
        let calendar = Calendar.current
        let now = Date()

        return expenses.filter { expense in
            let date = expense.date

            switch selectedPeriod {
            case .all:
                return true

            case .thisMonth:
                let d = calendar.dateComponents([.year, .month], from: date)
                let n = calendar.dateComponents([.year, .month], from: now)
                return d.year == n.year && d.month == n.month

            case .lastMonth:
                guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) else {
                    return false
                }
                let d = calendar.dateComponents([.year, .month], from: date)
                let lm = calendar.dateComponents([.year, .month], from: lastMonthDate)
                return d.year == lm.year && d.month == lm.month

            case .last3Months:
                guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
                    return false
                }
                // From start of day three months ago to now
                let start = calendar.startOfDay(for: threeMonthsAgo)
                return (date >= start && date <= now)
            }
        }
    }

    // MARK: - Derived Data

    private var dailyTotals: [DailyTotal] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            calendar.startOfDay(for: expense.date)
        }

        return grouped.map { (day, items) in
            let total = items.reduce(0) { $0 + $1.amount }
            return DailyTotal(date: day, total: total)
        }
        .sorted { $0.date < $1.date }
    }

    private var categoryTotals: [CategoryTotal] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            expense.category
        }

        return grouped.map { (category, items) in
            let total = items.reduce(0) { $0 + $1.amount }
            return CategoryTotal(category: category, total: total)
        }
        .sorted { $0.total > $1.total } // highest spend first
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                // Mode picker (Daily / Category)
                Picker("Mode", selection: $selectedMode) {
                    Text("Daily").tag(AnalyticsMode.daily)
                    Text("By Category").tag(AnalyticsMode.category)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                // Month filter picker
                HStack {
                    Text("Period")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(MonthFilterOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)

                // Chart content
                if filteredExpenses.isEmpty {
                    Spacer()
                    Text("No data for this period. Try changing the filter or add some expenses.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    switch selectedMode {
                    case .daily:
                        dailyChartSection
                    case .category:
                        categoryChartSection
                    }
                }

                Spacer()
            }
            .navigationTitle("Analytics")
        }
    }

    // MARK: - Daily Chart

    private var dailyChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Spending")
                .font(.headline)
                .padding(.horizontal)

            if dailyTotals.isEmpty {
                Text("No daily data in this period.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                Chart(dailyTotals) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Total", item.total)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding(.horizontal)
                .frame(height: 260)
            }
        }
    }

    // MARK: - Category Chart

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.horizontal)

            if categoryTotals.isEmpty {
                Text("No category data in this period.")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            } else {
                Chart(categoryTotals) { item in
                    BarMark(
                        x: .value("Amount", item.total),
                        y: .value("Category", item.category)
                    )
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .padding(.horizontal)
                .frame(height: 260)
            }
        }
    }
}

// MARK: - Types

enum AnalyticsMode: Hashable {
    case daily
    case category
}

enum MonthFilterOption: String, CaseIterable, Identifiable {
    case all
    case thisMonth
    case lastMonth
    case last3Months

    var id: Self { self }

    var title: String {
        switch self {
        case .all:        return "All Time"
        case .thisMonth:  return "This Month"
        case .lastMonth:  return "Last Month"
        case .last3Months:return "Last 3 Months"
        }
    }
}

struct DailyTotal: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
}

struct CategoryTotal: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}

#Preview {
    ExpenseAnalyticsView()
        .modelContainer(for: ExpenseModel.self)
}

import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context

    // All expenses from SwiftData, newest first
    @Query(sort: \ExpenseModel.date, order: .reverse)
    private var expenses: [ExpenseModel]

    @State private var showingAddExpense = false
    @State private var expenseToEdit: ExpenseModel?    // for edit sheet

    // MARK: - Computed totals

    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var thisMonthAmount: Double {
        // TODO: refine later to actual month filter if you want
        totalAmount
    }

    private var todayAmount: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Grouping

    private var todayExpenses: [ExpenseModel] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDateInToday($0.date) }
    }

    private var thisWeekExpenses: [ExpenseModel] {
        let calendar = Calendar.current
        return expenses.filter { exp in
            // same weekOfYear & year as today, but NOT today
            let now = Date()
            return !calendar.isDateInToday(exp.date) &&
                   calendar.component(.weekOfYear, from: exp.date) == calendar.component(.weekOfYear, from: now) &&
                   calendar.component(.yearForWeekOfYear, from: exp.date) == calendar.component(.yearForWeekOfYear, from: now)
        }
    }

    private var olderExpenses: [ExpenseModel] {
        let calendar = Calendar.current
        return expenses.filter { exp in
            // not today and not in this week
            if calendar.isDateInToday(exp.date) { return false }

            let now = Date()
            let sameWeek = calendar.component(.weekOfYear, from: exp.date) == calendar.component(.weekOfYear, from: now) &&
                           calendar.component(.yearForWeekOfYear, from: exp.date) == calendar.component(.yearForWeekOfYear, from: now)

            return !sameWeek
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                // Summary card
                ExpenseSummaryView(
                    total: totalAmount,
                    month: thisMonthAmount,
                    today: todayAmount
                )
                .padding(.horizontal)

                if expenses.isEmpty {
                    Text("No expenses yet. Tap “+” to add one.")
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List {
                        // Today section
                        if !todayExpenses.isEmpty {
                            Section("Today") {
                                ForEach(todayExpenses) { exp in
                                    rowButton(for: exp)
                                }
                                .onDelete { offsets in
                                    delete(offsets, in: todayExpenses)
                                }
                            }
                        }

                        // This Week section
                        if !thisWeekExpenses.isEmpty {
                            Section("This Week") {
                                ForEach(thisWeekExpenses) { exp in
                                    rowButton(for: exp)
                                }
                                .onDelete { offsets in
                                    delete(offsets, in: thisWeekExpenses)
                                }
                            }
                        }

                        // Older section
                        if !olderExpenses.isEmpty {
                            Section("Older") {
                                ForEach(olderExpenses) { exp in
                                    rowButton(for: exp)
                                }
                                .onDelete { offsets in
                                    delete(offsets, in: olderExpenses)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true    // add mode
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Add (mode: .add)
            .sheet(isPresented: $showingAddExpense) {
                ExpenseFormView(mode: .add)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            // Edit (mode: .edit)
            .sheet(item: $expenseToEdit) { expense in
                ExpenseFormView(mode: .edit, expense: expense)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Row View

    private func rowButton(for exp: ExpenseModel) -> some View {
        Button {
            expenseToEdit = exp
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(exp.title)
                        .font(.headline)
                    Text(exp.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("₹\(Int(exp.amount))")
            }
        }
    }

    // MARK: - Delete

    private func delete(_ offsets: IndexSet, in section: [ExpenseModel]) {
        for index in offsets {
            let expense = section[index]
            context.delete(expense)
        }
    }
}

#Preview {
    ExpenseListView()
        .modelContainer(for: ExpenseModel.self)
}

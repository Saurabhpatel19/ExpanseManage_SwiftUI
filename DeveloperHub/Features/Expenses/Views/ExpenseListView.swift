import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context

    // All expenses from SwiftData, newest first
    @Query(sort: \ExpenseModel.date, order: .reverse)
    private var expenses: [ExpenseModel]

    @State private var showingAddExpense = false
    @State private var expenseToEdit: ExpenseModel?      // for edit sheet
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false         // 👈 search bar active/open?
    @State private var selectedCategory: ExpenseCategory? = nil

    // MARK: - Totals (overall, not filtered)

    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var thisMonthAmount: Double {
        totalAmount   // refine later if needed
    }

    private var todayAmount: Double {
        let calendar = Calendar.current
        return expenses
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Filtering (category ALWAYS, search if text present)

    /// 1) Apply category filter if selected
    /// 2) Apply search filter if searchText is non-empty
    private var activeExpenses: [ExpenseModel] {
        // Step 1: category filter (always active)
        var result: [ExpenseModel]
        if let selectedCategory {
            result = expenses.filter { $0.category == selectedCategory.rawValue }
        } else {
            result = expenses
        }

        // Step 2: search filter (only if text present)
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return result }

        let lower = trimmed.lowercased()
        return result.filter { exp in
            exp.title.lowercased().contains(lower) ||
            exp.category.lowercased().contains(lower)
        }
    }

    // MARK: - Grouping with active list

    private var todayExpenses: [ExpenseModel] {
        let cal = Calendar.current
        return activeExpenses.filter { cal.isDateInToday($0.date) }
    }

    private var thisWeekExpenses: [ExpenseModel] {
        let cal = Calendar.current
        let now = Date()
        return activeExpenses.filter { exp in
            !cal.isDateInToday(exp.date) &&
            cal.component(.weekOfYear, from: exp.date) == cal.component(.weekOfYear, from: now) &&
            cal.component(.yearForWeekOfYear, from: exp.date) == cal.component(.yearForWeekOfYear, from: now)
        }
    }

    private var olderExpenses: [ExpenseModel] {
        let cal = Calendar.current
        let now = Date()
        return activeExpenses.filter { exp in
            if cal.isDateInToday(exp.date) { return false }
            let sameWeek =
                cal.component(.weekOfYear, from: exp.date) == cal.component(.weekOfYear, from: now) &&
                cal.component(.yearForWeekOfYear, from: exp.date) == cal.component(.yearForWeekOfYear, from: now)
            return !sameWeek
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // Top section: summary + chips + (optional) filter bubble
                Section {
                    // Summary card
                    ExpenseSummaryView(
                        total: totalAmount,
                        month: thisMonthAmount,
                        today: todayAmount
                    )
                    .listRowInsets(EdgeInsets()) // full-width card
                    .padding(.vertical, 4)

                    // Category chips row – ALWAYS visible
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            CategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
                                    selectedCategory = nil
                                }
                            }

                            ForEach(ExpenseCategory.allCases) { cat in
                                CategoryChip(
                                    title: cat.rawValue,
                                    isSelected: selectedCategory == cat
                                ) {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
                                        if selectedCategory == cat {
                                            selectedCategory = nil
                                        } else {
                                            selectedCategory = cat
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }


                    // Filter bubble – show ONLY when:
                    // 1) search bar is active (isSearching == true)
                    // 2) a category is selected (not All)
                    if isSearching, let selected = selectedCategory {
                        HStack(spacing: 8) {
                            Text("Filter:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 6) {
                                Text(selected.rawValue)
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(999)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                let hasAny = !todayExpenses.isEmpty || !thisWeekExpenses.isEmpty || !olderExpenses.isEmpty

                if !hasAny {
                    Section {
                        Text(
                            searchText.isEmpty && selectedCategory == nil
                            ? "No expenses yet. Tap “+” to add one."
                            : "No expenses found for this filter."
                        )
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 16)
                    }
                } else {
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showingAddExpense = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // 👇 iOS 17 searchable with isPresented binding
            .searchable(
                text: $searchText,
                isPresented: $isSearching,
                prompt: "Search in title/category"
            )
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

    // MARK: - Category chip (top row, always visible)

    private func categoryChip(title: String, category: ExpenseCategory?) -> some View {
        let isSelected = (category == nil && selectedCategory == nil) ||
                         (category != nil && category == selectedCategory)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
                if let category {
                    if selectedCategory == category {
                        selectedCategory = nil
                    } else {
                        selectedCategory = category
                    }
                } else {
                    selectedCategory = nil
                }
            }
        } label: {
            Text(title)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    isSelected
                    ? Color.blue.opacity(0.2)
                    : Color.gray.opacity(0.15)
                )
                .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }

    // MARK: - Delete

    private func delete(_ offsets: IndexSet, in section: [ExpenseModel]) {
        withAnimation(.easeInOut(duration: 0.2)) {
            for index in offsets {
                let expense = section[index]
                context.delete(expense)
            }
        }
    }
}

#Preview {
    ExpenseListView()
        .modelContainer(for: ExpenseModel.self)
}

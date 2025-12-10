import SwiftUI
import SwiftData

struct ExpenseFormView: View {
    enum Mode {
        case add
        case edit
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let mode: Mode
    let expense: ExpenseModel?      // nil for add, non-nil for edit

    @State private var title: String
    @State private var amount: String
    @State private var date: Date
    @State private var category: ExpenseCategory

    // MARK: - Init

    init(mode: Mode, expense: ExpenseModel? = nil) {
        self.mode = mode
        self.expense = expense

        _title = State(initialValue: expense?.title ?? "")
        _amount = State(initialValue: expense != nil ? String(expense!.amount) : "")
        _date = State(initialValue: expense?.date ?? Date())

        let initialCategory = ExpenseCategory(rawValue: expense?.category ?? "") ?? .food
        _category = State(initialValue: initialCategory)
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title (e.g. Coffee, Uber)", text: $title)

                    TextField("Amount (₹)", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(mode == .add ? "New Expense" : "Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveExpense() }
                        .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Save

    private func saveExpense() {
        guard
            !title.trimmingCharacters(in: .whitespaces).isEmpty,
            let amountValue = Double(amount)
        else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            switch mode {
            case .add:
                let new = ExpenseModel(
                    title: title,
                    category: category.rawValue,
                    amount: amountValue,
                    date: date
                )
                context.insert(new)

            case .edit:
                if let expense {
                    expense.title = title
                    expense.category = category.rawValue
                    expense.amount = amountValue
                    expense.date = date
                    // SwiftData auto-saves
                }
            }
        }

        dismiss()
    }
}

#Preview {
    ExpenseFormView(mode: .add)
        .modelContainer(for: ExpenseModel.self)
}

import SwiftUI

struct AddTransactionView: View {
    @StateObject private var viewModel = AddTransactionViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var isExpense: Bool = true
    @State private var selectedCategoryId: UUID?
    @State private var selectedCardId: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $title)
                    
                    TextField("Сумма", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Тип", selection: $isExpense) {
                        Text("Расход").tag(true)
                        Text("Доход").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Категория")) {
                    // Сетка категорий
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(viewModel.categories.filter { isExpense ? $0.isExpenseCategory : !$0.isExpenseCategory }) { category in
                            CategoryItemView(
                                category: category,
                                isSelected: selectedCategoryId == category.id
                            )
                            .onTapGesture {
                                selectedCategoryId = category.id
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Дополнительно")) {
                    TextField("Описание", text: $description)
                    
                    Picker("Карта", selection: $selectedCardId) {
                        Text("Не выбрана").tag(nil as UUID?)
                        ForEach(viewModel.cards) { card in
                            Text("\(card.bank) - \(maskCardNumber(card.cardNumber))").tag(card.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Новая транзакция")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    guard let amountValue = Double(amount),
                          let categoryId = selectedCategoryId,
                          let category = viewModel.categories.first(where: { $0.id == categoryId }) else {
                        return
                    }
                    
                    let transaction = Transaction(
                        id: UUID(),
                        amount: amountValue,
                        title: title,
                        description: description,
                        category: category,
                        date: date,
                        cardId: selectedCardId,
                        isExpense: isExpense
                    )
                    
                    viewModel.saveTransaction(transaction)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || amount.isEmpty || selectedCategoryId == nil)
            )
        }
        .onAppear {
            viewModel.fetchCategories()
            viewModel.fetchCards()
        }
    }
    
    private func maskCardNumber(_ number: String) -> String {
        let last4 = String(number.suffix(4))
        return "••••" + last4
    }
}

struct CategoryItemView: View {
    var category: Category
    var isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : category.color)
                .frame(width: 50, height: 50)
                .background(isSelected ? category.color : category.color.opacity(0.2))
                .cornerRadius(12)
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
    }
}

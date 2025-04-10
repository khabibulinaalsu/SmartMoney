import SwiftUI

struct TransactionsView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedTimeFrame: TimeFrame = .month
    
    var body: some View {
        NavigationView {
            VStack {
                // Picker для выбора временного промежутка
                Picker("Период", selection: $selectedTimeFrame) {
                    Text("Неделя").tag(TimeFrame.week)
                    Text("Месяц").tag(TimeFrame.month)
                    Text("Год").tag(TimeFrame.year)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Диаграммы
                VStack {
                    Text("Расходы по категориям")
                        .font(.headline)
                    
                    // Круговая диаграмма
                    PieChartView(data: viewModel.categoryDistribution)
                        .frame(height: 200)
                        .padding()
                    
//                    // Гистограмма
//                    BarChartView(data: viewModel.dailyExpenses)
//                        .frame(height: 150)
//                        .padding()
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
                
                // Список транзакций
                List {
                    ForEach(viewModel.transactions) { transaction in
//                        Section(header: Text(section.key.formatted(date: .abbreviated, time: .omitted))) {
                        TransactionRowView(transaction: transaction)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Транзакции")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTransactionView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTransactions(for: selectedTimeFrame)
        }
        .onChange(of: selectedTimeFrame) { newValue in
            viewModel.fetchTransactions(for: newValue)
        }
    }
}

enum TimeFrame {
    case week, month, year
}

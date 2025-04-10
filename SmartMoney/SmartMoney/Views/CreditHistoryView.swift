import SwiftUI

struct CreditHistoryView: View {
    @StateObject private var viewModel = CreditHistoryViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // Сводка кредитной истории
                Section(header: Text("Сводка")) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Общая сумма кредитов")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.totalCreditAmount, specifier: "%.2f") ₽")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Остаток задолженности")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.totalRemainingAmount, specifier: "%.2f") ₽")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.totalRemainingAmount > 0 ? .red : .green)
                            }
                        }
                        
                        // Прогресс-бар погашения кредитов
                        ProgressView(value: viewModel.totalRemainingAmount == 0 ? 1 : (viewModel.totalCreditAmount - viewModel.totalRemainingAmount) / viewModel.totalCreditAmount)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.vertical, 10)
                }
                
                // Список активных кредитов
                Section(header: Text("Активные кредиты")) {
                    if viewModel.activeCredits.isEmpty {
                        Text("У вас нет активных кредитов")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(viewModel.activeCredits) { credit in
                            NavigationLink(destination: CreditDetailView(credit: credit)) {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
                }
                
                // Список закрытых кредитов
                Section(header: Text("Закрытые кредиты")) {
                    if viewModel.closedCredits.isEmpty {
                        Text("У вас нет закрытых кредитов")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(viewModel.closedCredits) { credit in
                            NavigationLink(destination: CreditDetailView(credit: credit)) {
                                CreditRowView(credit: credit)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Кредитная история")
        }
        .onAppear {
            viewModel.fetchCreditHistory()
        }
    }
}

struct CreditRowView: View {
    var credit: CreditHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(credit.creditInstitution)
                    .font(.headline)
                
                Spacer()
                
                Text(credit.remainingAmount > 0 ? "Активный" : "Закрыт")
                    .font(.caption)
                    .padding(5)
                    .background(credit.remainingAmount > 0 ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                    .foregroundColor(credit.remainingAmount > 0 ? .blue : .green)
                    .cornerRadius(5)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Сумма кредита")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(credit.creditAmount, specifier: "%.2f") ₽")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Остаток")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(credit.remainingAmount, specifier: "%.2f") ₽")
                        .font(.subheadline)
                        .foregroundColor(credit.remainingAmount > 0 ? .red : .green)
                }
            }
            
            // Прогресс-бар погашения
            ProgressView(value: credit.remainingAmount == 0 ? 1 : (credit.creditAmount - credit.remainingAmount) / credit.creditAmount)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
        .padding(.vertical, 5)
    }
}

struct CreditDetailView: View {
    var credit: CreditHistory
    
    var body: some View {
        List {
            Section(header: Text("Основная информация")) {
                InfoRow(title: "Кредитная организация", value: credit.creditInstitution)
                InfoRow(title: "Сумма кредита", value: "\(credit.creditAmount, specifier: "%.2f") ₽")
                InfoRow(title: "Остаток задолженности", value: "\(credit.remainingAmount, specifier: "%.2f") ₽")
                InfoRow(title: "Процентная ставка", value: "\(credit.interestRate, specifier: "%.2f")%")
                InfoRow(title: "Дата начала", value: formatDate(credit.startDate))
                InfoRow(title: "Дата окончания", value: formatDate(credit.endDate))
                InfoRow(title: "Ежемесячный платеж", value: "\(credit.monthlyPayment, specifier: "%.2f") ₽")
            }
            
            Section(header: Text("История платежей")) {
                ForEach(credit.paymentHistory.sorted(by: { $0.date > $1.date })) { payment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formatDate(payment.date))
                                .font(.subheadline)
                            
                            Text(payment.status.displayText)
                                .font(.caption)
                                .foregroundColor(payment.status.color)
                        }
                        
                        Spacer()
                        
                        Text("\(payment.amount, specifier: "%.2f") ₽")
                            .font(.headline)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Детали кредита")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    var title: String
    var value: LocalizedStringKey
    
    init(title: String, value: LocalizedStringKey) {
        self.title = title
        self.value = value
    }
    
    init(title: String, value: String) {
        self.title = title
        self.value = .init(value)
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}


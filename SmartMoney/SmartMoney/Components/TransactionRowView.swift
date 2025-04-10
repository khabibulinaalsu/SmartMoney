import SwiftUI

struct TransactionRowView: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .foregroundColor(transaction.category.color)
                .frame(width: 40, height: 40)
                .background(transaction.category.color.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.headline)
                Text(transaction.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.isExpense ? "-" : "+")\(transaction.amount, specifier: "%.2f") ₽")
                .font(.headline)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
    }
}

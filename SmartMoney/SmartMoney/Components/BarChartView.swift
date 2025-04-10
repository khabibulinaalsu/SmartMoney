import SwiftUI
import Charts

struct BarChartView: View {
    var data: [BarData]
    
    // Находим максимальную сумму для масштабирования
    private var maxAmount: Double {
        data.map { $0.amount }.max() ?? 0
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.indices, id: \.self) { index in
                    VStack {
                        // Полоска гистограммы
                        RoundedRectangle(cornerRadius: 5)
                            .fill(data[index].amount > 0 ?
                                  Color.blue.opacity(0.7) :
                                  Color.blue.opacity(0.2))
                            .frame(height: data[index].amount > 0 ?
                                   CGFloat(data[index].amount / maxAmount * 100) :
                                   2)
                        
                        // Дата под полоской
                        Text(formatDate(data[index].date))
                            .font(.system(size: 8))
                            .rotationEffect(.degrees(-45))
                            .frame(width: 20)
                            .fixedSize()
                    }
                }
            }
            .padding(.horizontal)
            .animation(.spring(), value: data)
            
            // Линия разделения
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}

struct BarData: Equatable {
    let date: Date
    let amount: Double
}

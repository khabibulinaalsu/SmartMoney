import SwiftUI
import Charts

struct PieChartView: View {
    var data: [(category: Category, amount: Double)]
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ZStack {
                    ForEach(0..<data.count, id: \.self) { index in
                        PieSliceView(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            color: data[index].category.color
                        )
                    }
                    
                    // Центральный круг для создания "бублика"
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                    
                    // Общая сумма в центре
                    VStack {
                        Text("Всего")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(totalAmount(), specifier: "%.0f") ₽")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                
                legendView()
                    .padding(.leading)
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        if index == 0 { return .degrees(0) }
        
        var sum: Double = 0
        for i in 0..<index {
            sum += data[i].amount
        }
        
        return .degrees(sum / totalAmount() * 360)
    }
    
    private func endAngle(for index: Int) -> Angle {
        var sum: Double = 0
        for i in 0...index {
            sum += data[i].amount
        }
        
        return .degrees(sum / totalAmount() * 360)
    }
    
    private func totalAmount() -> Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    @ViewBuilder
    private func legendView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(data, id: \.category.id) { item in
                HStack {
                    Circle()
                        .fill(item.category.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.category.name)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(item.amount / totalAmount() * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if data.count > 5 {
                Text("и еще \(data.count - 5)...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
    }
}

struct PieSliceView: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

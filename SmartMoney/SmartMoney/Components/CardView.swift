import SwiftUI

struct CardView: View {
    var card: Card
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(card.bank)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: card.cardType == .credit ? "creditcard" : "creditcard.fill")
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(maskCardNumber(card.cardNumber))
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Владелец")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(card.cardHolderName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Срок")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(expiryDateFormatted(card.expiryDate))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [card.color, card.color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 5)
    }
    
    private func maskCardNumber(_ number: String) -> String {
        let last4 = String(number.suffix(4))
        return "•••• •••• •••• " + last4
    }
    
    private func expiryDateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter.string(from: date)
    }
}


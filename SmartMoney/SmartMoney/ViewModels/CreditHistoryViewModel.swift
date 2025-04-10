import SwiftUI

class CreditHistoryViewModel: ObservableObject {
    @Published var activeCredits: [CreditHistory] = []
    @Published var closedCredits: [CreditHistory] = []
    @Published var totalCreditAmount: Double = 0
    @Published var totalRemainingAmount: Double = 0
    
    private let dataManager = DataManager.shared
    
    func fetchCreditHistory() {
        let allCredits = dataManager.fetchCreditHistory()
        
        // Разделяем на активные и закрытые кредиты
        activeCredits = allCredits.filter { $0.remainingAmount > 0 }
        closedCredits = allCredits.filter { $0.remainingAmount <= 0 }
        
        // Обновляем суммарные показатели
        totalCreditAmount = allCredits.reduce(0) { $0 + $1.creditAmount }
        totalRemainingAmount = allCredits.reduce(0) { $0 + $1.remainingAmount }
    }
    
    func addNewCredit(_ credit: CreditHistory) {
        dataManager.saveCredit(credit)
        fetchCreditHistory()
    }
    
    func updateCredit(_ credit: CreditHistory) {
        dataManager.updateCredit(credit)
        fetchCreditHistory()
    }
    
    func addPayment(to creditId: UUID, amount: Double) {
        guard var credit = (activeCredits + closedCredits).first(where: { $0.id == creditId }) else {
            return
        }
        
        // Создаем новый платеж
        let payment = Payment(
            id: UUID(),
            amount: amount,
            date: Date(),
            status: .paid
        )
        
        // Обновляем кредит
        credit.paymentHistory.append(payment)
        credit.remainingAmount = max(0, credit.remainingAmount - amount)
        
        updateCredit(credit)
    }
}

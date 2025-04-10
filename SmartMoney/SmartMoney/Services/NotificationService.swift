import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
            } else if let error = error {
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func schedulePaymentReminder(for credit: CreditHistory) {
        // Создаем уведомление за день до платежа
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о платеже"
        content.body = "Завтра платеж по кредиту в \(credit.creditInstitution) на сумму \(credit.monthlyPayment) ₽"
        content.sound = .default
        
        // Находим дату следующего платежа
        guard let nextPaymentDate = findNextPaymentDate(for: credit) else { return }
        
        // Создаем дату напоминания (за день до платежа)
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextPaymentDate)!
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
        
        // Создаем триггер и запрос
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "payment-\(credit.id.uuidString)", content: content, trigger: trigger)
        
        // Добавляем уведомление
        center.add(request)
    }
    
    func scheduleBudgetAlert(for budget: Budget, percentThreshold: Double = 0.8) {
        // Создаем уведомление, когда бюджет израсходован на определенный процент
        let content = UNMutableNotificationContent()
        content.title = "Предупреждение о бюджете"
        content.body = "Вы израсходовали \(Int(percentThreshold * 100))% вашего бюджета на \(budget.category?.name ?? "общие расходы")"
        content.sound = .default
        
        // Идентификатор для возможности обновления уведомления
        let identifier = "budget-\(budget.id.uuidString)-\(Int(percentThreshold * 100))"
        
        // Создаем запрос без триггера (будет доставлен немедленно)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        // Добавляем уведомление
        center.add(request)
    }
    
    func scheduleGoalReminder(for goal: FinancialGoal) {
        guard let targetDate = goal.targetDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Финансовая цель"
        content.body = "Напоминание о вашей цели: \(goal.title). Осталось накопить \(Int(goal.targetAmount - goal.currentAmount)) ₽"
        content.sound = .default
        
        // Создаем еженедельные напоминания
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Воскресенье
        dateComponents.hour = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "goal-\(goal.id.uuidString)", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func findNextPaymentDate(for credit: CreditHistory) -> Date? {
        // Находим дату следующего платежа по кредиту
        let today = Date()
        
        // Получаем день месяца для платежа из даты начала кредита
        let startDateComponents = Calendar.current.dateComponents([.day], from: credit.startDate)
        let paymentDay = startDateComponents.day ?? 1
        
        // Создаем компоненты даты для текущего месяца с днем платежа
        var components = Calendar.current.dateComponents([.year, .month], from: today)
        components.day = paymentDay
        
        var nextPaymentDate = Calendar.current.date(from: components)!
        
        // Если дата платежа в текущем месяце уже прошла, берем следующий месяц
        if nextPaymentDate < today {
            nextPaymentDate = Calendar.current.date(byAdding: .month, value: 1, to: nextPaymentDate)!
        }
        
        return nextPaymentDate
    }
}

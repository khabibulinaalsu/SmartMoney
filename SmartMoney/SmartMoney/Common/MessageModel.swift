import Foundation
import SwiftData

enum Sender: String, Codable {
    case ai = "ИИ-консультант"
    case user = "Вы"
}

@Model
final class MessageModel {
    var id: UUID
    var date: Date
    var text: String
    var sender: Sender
    
    init(id: UUID = UUID(), date: Date = Date(), text: String, sender: Sender) {
        self.id = id
        self.date = date
        self.text = text
        self.sender = sender
    }
}

import SwiftUI

struct Category: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: Color
    var isExpenseCategory: Bool
}

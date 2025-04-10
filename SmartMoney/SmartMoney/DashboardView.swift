import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "arrow.right.arrow.left.circle.fill")
                }
            CardManagementView()
                .tabItem {
                    Label("Cards", systemImage: "creditcard.circle.fill")
                }
            CreditHistoryView()
                .tabItem {
                    Label("Credit history", systemImage: "list.bullet.circle.fill")
                }
        }
    }
}



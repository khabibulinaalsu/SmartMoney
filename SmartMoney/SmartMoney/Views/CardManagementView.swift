import SwiftUI

struct CardManagementView: View {
    @StateObject private var viewModel = CardViewModel()
    @State private var showingAddCardSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Карусель существующих карт
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.cards) { card in
                                CardView(card: card)
                                    .frame(width: 300, height: 180)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                    
                    // Список карт
                    VStack {
                        ForEach(viewModel.cards) { card in
//                            CardListItemView(card: card) {
//                                viewModel.selectCard(card)
//                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Мои карты")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCardSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCardSheet) {
                AddCardView { newCard in
                    viewModel.addCard(newCard)
                    showingAddCardSheet = false
                }
            }
        }
        .onAppear {
            viewModel.fetchCards()
        }
    }
}


struct AddCardView: View {
    @State private var cardNumber: String = ""
    @State private var cardHolderName: String = ""
    @State private var expiryMonth: Int = 1
    @State private var expiryYear: Int = Calendar.current.component(.year, from: Date()) % 100
    @State private var cvv: String = ""
    @State private var bank: String = ""
    @State private var cardType: CardType = .debit
    @State private var color: Color = .blue
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: (Card) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о карте")) {
                    TextField("Номер карты", text: $cardNumber)
                        .keyboardType(.numberPad)
                    
                    TextField("Имя владельца", text: $cardHolderName)
                    
                    HStack {
                        Picker("Месяц", selection: $expiryMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)").tag(month)
                            }
                        }
                        
                        Picker("Год", selection: $expiryYear) {
                            ForEach(0..<10, id: \.self) { yearOffset in
                                let year = (Calendar.current.component(.year, from: Date()) % 100) + yearOffset
                                Text("\(year)").tag(year)
                            }
                        }
                    }
                    
                    SecureField("CVV", text: $cvv)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Дополнительно")) {
                    TextField("Банк", text: $bank)
                    
                    Picker("Тип карты", selection: $cardType) {
                        Text("Дебетовая").tag(CardType.debit)
                        Text("Кредитная").tag(CardType.credit)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    ColorPicker("Цвет карты", selection: $color)
                }
            }
            .navigationTitle("Добавить карту")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    let expiryDate = Calendar.current.date(from: DateComponents(year: 2000 + expiryYear, month: expiryMonth, day: 1)) ?? Date()
                    
                    let newCard = Card(
                        id: UUID(),
                        cardNumber: cardNumber,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        bank: bank,
                        cardType: cardType,
                        balance: 0,
                        currency: Currency.rub,
                        color: color
                    )
                    
                    onSave(newCard)
                }
                .disabled(cardNumber.isEmpty || cardHolderName.isEmpty || bank.isEmpty)
            )
        }
    }
}

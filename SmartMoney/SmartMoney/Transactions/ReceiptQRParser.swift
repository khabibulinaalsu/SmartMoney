
import Foundation

struct ReceiptQRParser {
    struct ReceiptData {
        let amount: Double
        let date: Date
        let merchant: String
        let fiscalDocument: String?
        let fiscalSign: String?
    }
    
    static func parseReceiptQR(_ qrString: String) -> ReceiptData? {
        // Парсинг QR-кода чека (формат ФНС России)
        // Пример: t=20220315T1230&s=1250.00&fn=9999078900004312&i=12345&fp=1234567890&n=1
        
        let components = qrString.components(separatedBy: "&")
        var params: [String: String] = [:]
        
        for component in components {
            let keyValue = component.components(separatedBy: "=")
            if keyValue.count == 2 {
                params[keyValue[0]] = keyValue[1]
            }
        }
        
        guard let amountString = params["s"],
              let amount = Double(amountString),
              let dateString = params["t"] else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmm"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        
        return ReceiptData(
            amount: amount,
            date: date,
            merchant: "Магазин", // Можно расширить парсинг для получения названия
            fiscalDocument: params["i"],
            fiscalSign: params["fp"]
        )
    }
}

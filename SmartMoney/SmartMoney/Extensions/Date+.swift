import Foundation

enum DateFormatters {
    static let time4Formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

extension Date {
    var time4: String {
        DateFormatters.time4Formatter.string(from: self)
    }
}

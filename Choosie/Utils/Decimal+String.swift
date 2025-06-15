import Foundation

extension Decimal {
    var stringValue: String {
        NSDecimalNumber(decimal: self).stringValue
    }
    
    init?(string: String) {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: string) {
            self = number.decimalValue
        } else {
            return nil
        }
    }
} 
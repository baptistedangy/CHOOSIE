import Foundation

class DrawResultViewModel: ObservableObject {
    let winnerName: String
    let amountWon: Decimal
    
    init(winnerName: String, amountWon: Decimal) {
        self.winnerName = winnerName
        self.amountWon = amountWon
    }
} 
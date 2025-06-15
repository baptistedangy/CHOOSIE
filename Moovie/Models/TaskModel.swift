import Foundation

struct TaskModel: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let totalAmount: Decimal
    let participantCount: Int
    let code: String
} 
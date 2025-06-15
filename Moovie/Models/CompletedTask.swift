import Foundation

struct CompletedTask: Identifiable, Codable {
    let id: UUID
    let taskName: String
    let totalAmount: Double
    let participants: [String]
    let winner: String
    let createdBy: UUID
    let date: Date
} 
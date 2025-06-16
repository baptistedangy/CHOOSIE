import Foundation

struct CompletedMission: Identifiable, Codable {
    let id: UUID
    let missionName: String
    let totalAmount: Double
    let participants: [String]
    let winner: String
    let createdBy: UUID
    let date: Date
} 
import Foundation

struct MissionModel: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let code: String
    let inviteCode: String
    var loserName: String? = nil
    var isPending: Bool = false
    let minAmount: Double
} 
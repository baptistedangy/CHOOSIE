import Foundation

struct MissionModel: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let totalAmount: Decimal
    let participantCount: Int
    let code: String
    let inviteCode: String
    var loserName: String? = nil
} 
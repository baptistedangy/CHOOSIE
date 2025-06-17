import Foundation

enum DrawType: String, Codable, Hashable {
    case immediate
    case scheduled
}

struct MissionModel: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let code: String
    let inviteCode: String
    var loserName: String? = nil
    let drawType: DrawType
    let drawDate: Date?
} 
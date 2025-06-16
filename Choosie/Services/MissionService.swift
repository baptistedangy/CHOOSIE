import Foundation

class MissionService {
    static let shared = MissionService()
    private init() {}

    @Published private(set) var missions: [MissionModel] = []

    func addMission(_ mission: MissionModel) {
        missions.append(mission)
    }

    func getMission(by inviteCode: String) -> MissionModel? {
        return missions.first { $0.inviteCode.lowercased() == inviteCode.lowercased() }
    }
} 
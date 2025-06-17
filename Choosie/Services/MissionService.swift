import Foundation

class MissionService: ObservableObject {
    static let shared = MissionService()
    private init() {}

    @Published private(set) var missions: [MissionModel] = []

    func addMission(_ mission: MissionModel) {
        missions.append(mission)
    }

    func getMission(by inviteCode: String) -> MissionModel? {
        return missions.first { $0.inviteCode.lowercased() == inviteCode.lowercased() }
    }

    func markMissionAsPending(_ mission: MissionModel) {
        if let idx = missions.firstIndex(where: { $0.id == mission.id }) {
            missions[idx].isPending = true
            missions = missions
        }
    }

    func markMissionAsPending(inviteCode: String) {
        if let idx = missions.firstIndex(where: { $0.inviteCode.lowercased() == inviteCode.lowercased() }) {
            missions[idx].isPending = true
            missions = missions
        }
    }
} 
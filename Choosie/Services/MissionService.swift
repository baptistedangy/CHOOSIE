import Foundation

class MissionService: ObservableObject {
    static let shared = MissionService()
    private init() {
        load()
    }

    @Published private(set) var missions: [MissionModel] = [] {
        didSet {
            save()
        }
    }

    private let storageKey = "missions_en_attente"

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

    func removeMission(_ mission: MissionModel) {
        missions.removeAll { $0.id == mission.id }
    }

    // Persistance locale
    private func save() {
        if let data = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([MissionModel].self, from: data) {
            self.missions = decoded
        }
    }
} 
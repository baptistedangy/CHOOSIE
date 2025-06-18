import Foundation

class MissionHistoryManager: ObservableObject {
    static let shared = MissionHistoryManager()
    private let storageKey = "completedMissions"
    @Published private(set) var missions: [CompletedMission] = []
    
    private init() {
        load()
        if missions.isEmpty {
            addSampleMissions()
        }
    }
    
    func addMission(_ mission: CompletedMission) {
        missions.append(mission)
        save()
    }
    
    func fetchMissions() -> [CompletedMission] {
        missions
    }
    
    func removeMission(_ mission: CompletedMission) {
        missions.removeAll { $0.id == mission.id }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CompletedMission].self, from: data) {
            self.missions = decoded
        }
    }
    
    private func addSampleMissions() {
        let userId = UUID(uuidString: UserManager.shared.userId) ?? UUID()
        let now = Date()
        let samples: [CompletedMission] = [
            CompletedMission(
                id: UUID(),
                missionName: "Courses",
                totalAmount: 40.0,
                participants: [UserManager.shared.displayName, "Alex", "Sam"],
                winner: "Alex",
                createdBy: userId,
                date: now.addingTimeInterval(-86400)
            ),
            CompletedMission(
                id: UUID(),
                missionName: "Nettoyage garage",
                totalAmount: 60.0,
                participants: ["Jordan", UserManager.shared.displayName, "Charlie"],
                winner: UserManager.shared.displayName,
                createdBy: UUID(),
                date: now.addingTimeInterval(-172800)
            ),
            CompletedMission(
                id: UUID(),
                missionName: "Sortie poubelles",
                totalAmount: 10.0,
                participants: ["Morgan", UserManager.shared.displayName],
                winner: "Morgan",
                createdBy: userId,
                date: now.addingTimeInterval(-259200)
            )
        ]
        self.missions = samples
        save()
    }
} 
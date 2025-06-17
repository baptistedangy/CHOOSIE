import Foundation

class CreateMissionViewModel: ObservableObject {
    @Published var missionName: String = ""
    @Published var generatedCode: String? = nil
    @Published var lastCreatedMission: MissionModel? = nil

    var canCreate: Bool {
        !missionName.isEmpty
    }

    func createMission() -> Bool {
        guard canCreate else { return false }
        let code = Self.generateUniqueCode()
        self.generatedCode = code
        let mission = MissionModel(
            id: UUID(),
            name: missionName,
            code: code,
            inviteCode: UUID().uuidString.prefix(6).uppercased(),
            loserName: nil,
            isPending: false
        )
        MissionService.shared.addMission(mission)
        self.lastCreatedMission = mission
        return true
    }

    private static func generateUniqueCode() -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        let minLen = 4, maxLen = 5
        let allCodes = MissionService.shared.missions.map { $0.inviteCode }
        var code: String
        repeat {
            let len = Int.random(in: minLen...maxLen)
            code = String((0..<len).map { _ in chars.randomElement()! })
        } while allCodes.contains(code)
        return code
    }
} 
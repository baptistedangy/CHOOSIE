import Foundation

class CreateMissionViewModel: ObservableObject {
    @Published var missionName: String = ""
    @Published var generatedCode: String? = nil
    @Published var lastCreatedMission: MissionModel? = nil
    @Published var minAmount: Double? = nil

    var canCreate: Bool {
        !missionName.isEmpty
    }

    var canCreateJackpot: Bool {
        !missionName.isEmpty && (minAmount ?? 0) >= 1
    }

    func createMission() -> Bool {
        guard canCreate else { return false }
        let code = Self.generateUniqueCode()
        self.generatedCode = code
        let mission = MissionModel(
            id: UUID(),
            name: missionName,
            code: code,
            inviteCode: code,
            loserName: nil,
            isPending: false,
            minAmount: minAmount ?? 1
        )
        MissionService.shared.addMission(mission)
        self.lastCreatedMission = mission
        return true
    }

    func createJackpot() -> Bool {
        guard canCreateJackpot else { return false }
        let code = Self.generateUniqueCode()
        self.generatedCode = code
        let mission = MissionModel(
            id: UUID(),
            name: missionName,
            code: code,
            inviteCode: code,
            loserName: nil,
            isPending: false,
            minAmount: minAmount ?? 1
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
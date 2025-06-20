import Foundation

class CreateMissionViewModel: ObservableObject {
    @Published var missionName: String = ""
    @Published var generatedCode: String? = nil
    @Published var lastCreatedMission: MissionModel? = nil
    @Published var minAmount: Double = 0.0
    @Published var errorMessage: String?

    var canCreate: Bool {
        !missionName.isEmpty
    }

    var canCreateJackpot: Bool {
        !missionName.isEmpty && minAmount > 0
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
            minAmount: minAmount,
            createdBy: UserManager.shared.userId
        )
        MissionService.shared.addMission(mission)
        self.lastCreatedMission = mission
        return true
    }

    func createJackpot() -> MissionModel? {
        guard canCreateJackpot else {
            if missionName.isEmpty {
                errorMessage = "Veuillez donner un nom à votre Jackpot"
            } else if minAmount <= 0 {
                errorMessage = "Le montant minimum doit être supérieur à 0"
            }
            return nil
        }

        let code = Self.generateUniqueCode()
        let mission = MissionModel(
            id: UUID(),
            name: missionName,
            code: code,
            inviteCode: code,
            loserName: nil,
            isPending: false,
            minAmount: minAmount,
            createdBy: UserManager.shared.userId
        )
        
        MissionService.shared.addMission(mission)
        return mission
    }

    private static func generateUniqueCode() -> String {
        let chars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let codeLength = 6
        let allCodes = MissionService.shared.missions.map { $0.inviteCode }
        var code: String
        repeat {
            code = String((0..<codeLength).map { _ in chars.randomElement()! })
        } while allCodes.contains(code)
        return code
    }
} 
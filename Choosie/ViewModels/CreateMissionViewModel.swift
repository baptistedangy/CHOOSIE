import Foundation

class CreateMissionViewModel: ObservableObject {
    @Published var missionName: String = ""
    @Published var totalAmountString: String = ""
    @Published var participantCount: Int = 2
    @Published var generatedCode: String? = nil
    @Published var totalAmount: Decimal = 0
    @Published var isCustomAmount: Bool = false

    var canCreate: Bool {
        guard !missionName.isEmpty,
              totalAmount > 0,
              participantCount >= 2 else { return false }
        return true
    }

    func createMission() -> Bool {
        guard canCreate else { return false }
        let code = Self.generateUniqueCode()
        self.generatedCode = code
        let mission = MissionModel(name: missionName, totalAmount: totalAmount, participantCount: participantCount, code: code, inviteCode: code)
        MissionService.shared.addMission(mission)
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
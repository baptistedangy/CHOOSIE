import Foundation

class CreateMissionViewModel: ObservableObject {
    @Published var missionName: String = ""
    @Published var generatedCode: String? = nil
    @Published var drawType: DrawType = .immediate
    @Published var drawDate: Date? = nil

    var canCreate: Bool {
        guard !missionName.isEmpty else { return false }
        if drawType == .scheduled {
            return drawDate != nil
        }
        return true
    }

    func createMission() -> Bool {
        guard canCreate else { return false }
        let code = Self.generateUniqueCode()
        self.generatedCode = code
        let mission = MissionModel(
            name: missionName,
            code: code,
            inviteCode: code,
            drawType: drawType,
            drawDate: drawType == .scheduled ? drawDate : nil
        )
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
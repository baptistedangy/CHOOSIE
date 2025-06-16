import Foundation

class JoinMissionViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var errorMessage: String? = nil
    @Published var foundMission: MissionModel? = nil

    var canJoin: Bool {
        code.count >= 4 && code.count <= 5 && code.range(of: "^[a-z0-9]{4,5}$", options: .regularExpression) != nil
    }

    func joinMission() -> Bool {
        errorMessage = nil
        guard canJoin else {
            errorMessage = "Le code doit comporter 4 à 5 caractères (lettres minuscules ou chiffres)."
            return false
        }
        let lowercasedCode = code.lowercased()
        if let mission = MissionService.shared.getMission(by: lowercasedCode) {
            foundMission = mission
            return true
        } else {
            errorMessage = "Aucune mission trouvée pour ce code."
            return false
        }
    }
} 
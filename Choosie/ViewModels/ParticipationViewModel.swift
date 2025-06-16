import Foundation

struct Participant: Identifiable {
    let id = UUID()
    let name: String
    var hasPaid: Bool
}

class ParticipationViewModel: ObservableObject {
    let mission: MissionModel
    @Published var participants: [Participant]
    @Published var hasPaid: Bool = false
    @Published var drawResult: (winner: Participant, amount: Decimal)? = nil

    var amountPerParticipant: Decimal {
        guard mission.participantCount > 0 else { return 0 }
        return (mission.totalAmount / Decimal(mission.participantCount))
    }

    var allPaid: Bool {
        participants.allSatisfy { $0.hasPaid }
    }

#if DEBUG
    static let dummyNames = ["Alex", "Sam", "Charlie", "Jordan", "Morgan", "Taylor", "Casey", "Riley", "Jamie", "Robin", "Drew", "Avery", "Quinn", "Skyler", "Jules", "Sacha", "Noa", "Eli", "Lou", "Milan", "Luca"]
#endif

    init(mission: MissionModel) {
        self.mission = mission
        // Le premier participant est l'utilisateur courant
        self.participants = [Participant(name: "Moi", hasPaid: false)]
#if DEBUG
        // Ajouter des participants fictifs payés pour atteindre le nombre requis
        let needed = max(0, mission.participantCount - 1)
        var usedNames = Set(["Moi"])
        for _ in 0..<needed {
            var name: String
            repeat {
                name = Self.dummyNames.randomElement() ?? "Invité"
            } while usedNames.contains(name)
            usedNames.insert(name)
            self.participants.append(Participant(name: name, hasPaid: true))
        }
#else
        // En production, tous les participants sont non payés
        for i in 2...mission.participantCount {
            self.participants.append(Participant(name: "Participant \(i)", hasPaid: false))
        }
#endif
    }

    func pay() {
        // Marquer l'utilisateur courant comme ayant payé
        if let idx = participants.firstIndex(where: { $0.name == "Moi" }) {
            participants[idx].hasPaid = true
            hasPaid = true
        }
    }

    func drawWinner() {
        let paidParticipants = participants.filter { $0.hasPaid }
        guard !paidParticipants.isEmpty else { return }
        if let winner = paidParticipants.randomElement() {
            drawResult = (winner, mission.totalAmount)
        }
    }

    func saveDrawResultToHistory() {
        guard let result = drawResult else { return }
        let completed = CompletedMission(
            id: UUID(),
            missionName: mission.name,
            totalAmount: NSDecimalNumber(decimal: mission.totalAmount).doubleValue,
            participants: participants.map { $0.name },
            winner: result.winner.name,
            createdBy: UUID(uuidString: UserManager.shared.userId) ?? UUID(),
            date: Date()
        )
        MissionHistoryManager.shared.addMission(completed)
    }

    func setLoserAndSaveHistory(loserName: String) {
        // Enregistrer le perdant dans la mission (si possible)
        // (Remarque : MissionModel est une struct, il faudrait le propager si besoin)
        // Enregistrer dans l'historique
        let completed = CompletedMission(
            id: UUID(),
            missionName: mission.name,
            totalAmount: NSDecimalNumber(decimal: mission.totalAmount).doubleValue,
            participants: participants.map { $0.name },
            winner: loserName,
            createdBy: UUID(uuidString: UserManager.shared.userId) ?? UUID(),
            date: Date()
        )
        MissionHistoryManager.shared.addMission(completed)
    }
} 
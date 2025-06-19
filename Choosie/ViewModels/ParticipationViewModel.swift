import Foundation

struct Participant: Identifiable {
    let id = UUID()
    let name: String
    var hasPaid: Bool
    var contribution: Decimal
}

class ParticipationViewModel: ObservableObject {
    let mission: MissionModel
    @Published var participants: [Participant]
    @Published var hasPaid: Bool = false
    @Published var drawResult: (winner: Participant, amount: Decimal)? = nil

    var amountPerParticipant: Decimal {
        return 0 // plus de montant par participant
    }

    var allPaid: Bool {
        participants.allSatisfy { $0.hasPaid }
    }

    var totalPot: Decimal {
        participants.reduce(0) { $0 + $1.contribution }
    }

    func emoji(for amount: Decimal) -> String {
        if amount < 2 { return "😇" }
        if amount > 50 { return "🤑" }
        if amount > 10 { return "💸" }
        return "🙂"
    }

#if DEBUG
    static let dummyNames = ["Alex", "Sam", "Charlie", "Jordan", "Morgan", "Taylor", "Casey", "Riley", "Jamie", "Robin", "Drew", "Avery", "Quinn", "Skyler", "Jules", "Sacha", "Noa", "Eli", "Lou", "Milan", "Luca"]
#endif

    init(mission: MissionModel) {
        self.mission = mission
        // Le premier participant est l'utilisateur courant, contribution par défaut au minimum
        self.participants = [Participant(name: "Moi", hasPaid: false, contribution: Decimal(mission.minAmount))]
#if DEBUG
        // Ajouter quelques participants fictifs pour le debug, contribution au minimum
        let needed = 2
        var usedNames = Set(["Moi"])
        for _ in 0..<needed {
            var name: String
            repeat {
                name = Self.dummyNames.randomElement() ?? "Invité"
            } while usedNames.contains(name)
            usedNames.insert(name)
            self.participants.append(Participant(name: name, hasPaid: true, contribution: Decimal(mission.minAmount)))
        }
#else
        // En production, tous les participants sont non payés (exemple statique)
        for i in 2...3 {
            self.participants.append(Participant(name: "Participant \(i)", hasPaid: false, contribution: Decimal(mission.minAmount)))
        }
#endif
    }

    func pay(amount: Decimal) {
        // Marquer l'utilisateur courant comme ayant payé et enregistrer le montant
        if let idx = participants.firstIndex(where: { $0.name == "Moi" }) {
            participants[idx].hasPaid = true
            participants[idx].contribution = amount
            hasPaid = true
        }
    }

    func drawWinner() {
        let paidParticipants = participants.filter { $0.hasPaid }
        guard !paidParticipants.isEmpty else { return }
        if let winner = paidParticipants.randomElement() {
            drawResult = (winner, 0)
        }
    }

    func saveDrawResultToHistory() {
        guard let result = drawResult else { return }
        let completed = CompletedMission(
            id: UUID(),
            missionName: mission.name,
            totalAmount: 0,
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
            totalAmount: 0,
            participants: participants.map { $0.name },
            winner: loserName,
            createdBy: UUID(uuidString: UserManager.shared.userId) ?? UUID(),
            date: Date()
        )
        MissionHistoryManager.shared.addMission(completed)
    }
} 
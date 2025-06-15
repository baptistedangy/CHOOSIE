import Foundation

struct Participant: Identifiable {
    let id = UUID()
    let name: String
    var hasPaid: Bool
}

class ParticipationViewModel: ObservableObject {
    let task: TaskModel
    @Published var participants: [Participant]
    @Published var hasPaid: Bool = false
    @Published var drawResult: (winner: Participant, amount: Decimal)? = nil

    var amountPerParticipant: Decimal {
        guard task.participantCount > 0 else { return 0 }
        return (task.totalAmount / Decimal(task.participantCount))
    }

    var allPaid: Bool {
        participants.allSatisfy { $0.hasPaid }
    }

#if DEBUG
    static let dummyNames = ["Alex", "Sam", "Charlie", "Jordan", "Morgan", "Taylor", "Casey", "Riley", "Jamie", "Robin", "Drew", "Avery", "Quinn", "Skyler", "Jules", "Sacha", "Noa", "Eli", "Lou", "Milan", "Luca"]
#endif

    init(task: TaskModel) {
        self.task = task
        // Le premier participant est l'utilisateur courant
        self.participants = [Participant(name: "Moi", hasPaid: false)]
#if DEBUG
        // Ajouter des participants fictifs payés pour atteindre le nombre requis
        let needed = max(0, task.participantCount - 1)
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
        for i in 2...task.participantCount {
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
            drawResult = (winner, task.totalAmount)
        }
    }
} 
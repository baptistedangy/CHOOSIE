import SwiftUI

struct ParticipationView: View {
    @StateObject private var viewModel: ParticipationViewModel
    @Binding var path: NavigationPath
    @State private var showDrawResult = false
    @State private var showSlotMachine = false
    @State private var slotLoserIndex: Int? = nil
    @State private var contributionText: String = "1"
    @State private var showContributionError: Bool = false

    init(mission: MissionModel, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: ParticipationViewModel(mission: mission))
        self._path = path
    }

    var body: some View {
        VStack {
            if let result = viewModel.drawResult {
                // Écran final simplifié après tirage
                VStack {
                    Spacer()
                    Text("🎉 Félicitations, \(result.winner.name) a été tiré au sort pour réaliser la mission !")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.purple)
                    Text("💰 Il reçoit \(amountFormatter(result.amount)) € pour l'accomplir.")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.bottom, 32)
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            path = NavigationPath()
                        }
                    }) {
                        Text("Retour à l'accueil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                }
                .frame(maxWidth: 500)
                .frame(maxHeight: .infinity, alignment: .center)
                .background(Color.gray.opacity(0.08))
                .padding()
            } else {
                VStack(spacing: 24) {
                    Text(viewModel.mission.name)
                        .font(.title)
                        .fontWeight(.bold)
                    if !viewModel.hasPaid {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quel montant veux-tu verser pour cette mission ?")
                                .font(.headline)
                            HStack {
                                TextField("Montant en €", text: $contributionText)
                                    .frame(width: 80)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text(viewModel.emoji(for: Decimal(string: contributionText) ?? 0))
                            }
                            if showContributionError {
                                Text("Montant minimum conseillé : 1€")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        Button(action: {
                            let amount = Decimal(string: contributionText) ?? 0
                            if amount < 1 {
                                showContributionError = true
                            } else {
                                showContributionError = false
                                viewModel.pay(amount: amount)
                            }
                        }) {
                            Text("Payer")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    } else {
                        Text("Paiement effectué ✅")
                            .foregroundColor(.green)
                    }
                    Divider()
                    Text("Participants")
                        .font(.headline)
                    List(viewModel.participants, id: \ .id) { participant in
                        HStack {
                            Text(participant.name)
                            Text("- \(amountFormatter(participant.contribution)) €")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(viewModel.emoji(for: participant.contribution))
                            Spacer()
                            if participant.hasPaid {
                                Text("Payé")
                                    .foregroundColor(.green)
                            } else {
                                Text("En attente")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .frame(height: 200)
                    Text("Cagnotte totale actuelle : \(amountFormatter(viewModel.totalPot)) €")
                        .font(.headline)
                        .padding(.top, 8)
                    if viewModel.allPaid && viewModel.drawResult == nil {
                        Button(action: {
                            showSlotMachine = true
                        }) {
                            Text("Lancer la machine à sous")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSlotMachine, onDismiss: {
            if let idx = slotLoserIndex {
                let loser = viewModel.participants[idx]
                viewModel.drawResult = (loser, 0)
                viewModel.setLoserAndSaveHistory(loserName: loser.name)
            }
        }) {
            SlotMachineView(participants: viewModel.participants.map { $0.name }, amount: 0) { loserIdx in
                slotLoserIndex = loserIdx
                showSlotMachine = false
            }
        }
    }

    private func amountFormatter(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(for: NSDecimalNumber(decimal: amount)) ?? "0.00"
    }
}

#Preview {
    @State var path = NavigationPath()
    ParticipationView(mission: MissionModel(id: UUID(), name: "Courses", code: "X4E2LQ", inviteCode: "abcd", loserName: nil, isPending: false), path: $path)
} 
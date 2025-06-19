import SwiftUI

struct ParticipationView: View {
    @StateObject private var viewModel: ParticipationViewModel
    @Binding var path: NavigationPath
    @State private var showDrawResult = false
    @State private var showSlotMachine = false
    @State private var slotLoserIndex: Int? = nil
    @State private var contributionText: String
    @State private var showContributionError: Bool = false
    @State private var tirageEffectue = false
    @State private var timer: Timer? = nil
    @State private var shouldNavigateToResult = false
    @State private var tiragePret = false
    @FocusState private var contributionFieldFocused: Bool

    init(mission: MissionModel, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: ParticipationViewModel(mission: mission))
        self._path = path
        self._contributionText = State(initialValue: String(format: "%.2f", mission.minAmount))
    }

    var body: some View {
        VStack {
            if shouldNavigateToResult, let result = viewModel.drawResult {
                DrawResultView(viewModel: DrawResultViewModel(winnerName: result.winner.name, amountWon: result.amount), path: $path)
            } else if let result = viewModel.drawResult {
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
                        VStack(alignment: .center, spacing: 24) {
                            // Carte paiement
                            VStack(alignment: .center, spacing: 14) {
                                Text("Quel montant veux-tu verser pour ce défi ?")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.choosieLila)
                                    .multilineTextAlignment(.center)
                                HStack(spacing: 0) {
                                    TextField("0.00 €", text: $contributionText)
                                        .font(.system(size: 28, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.choosieLila.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .frame(minWidth: 80, maxWidth: 160)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
#if os(iOS)
                                        .keyboardType(.decimalPad)
#endif
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color.white.opacity(0.08))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(
                                                    contributionFieldFocused ?
                                                        LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
                                                            : LinearGradient(gradient: Gradient(colors: [Color.clear, Color.clear]), startPoint: .leading, endPoint: .trailing),
                                                    lineWidth: 2.2
                                                )
                                                .shadow(color: contributionFieldFocused ? Color.purple.opacity(0.18) : .clear, radius: 8, x: 0, y: 2)
                                        )
                                        .focused($contributionFieldFocused)
                                        .animation(.easeOut(duration: 0.22), value: contributionFieldFocused)
                                    Text(" €")
                                        .font(.system(size: 28, weight: .regular, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                }
                                .frame(maxWidth: 220)
                                if showContributionError {
                                    Text("Montant minimum pour ce Jackpot : \(String(format: "%.2f", viewModel.mission.minAmount))€")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Text("Ce montant sera mis en jeu pour le tirage au sort.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 2)
                            }
                            .padding(24)
                            .background(Color.choosieCard)
                            .cornerRadius(20)
                            .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)
                            // Bouton payer
                            Button(action: {
                                let minAmount = NSDecimalNumber(decimal: Decimal(viewModel.mission.minAmount))
                                let amount = NSDecimalNumber(string: contributionText.replacingOccurrences(of: ",", with: "."))
                                if amount.compare(minAmount) == .orderedAscending {
                                    showContributionError = true
                                } else {
                                    showContributionError = false
                                    viewModel.pay(amount: amount.decimalValue)
                                }
                            }) {
                                Text("Payer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: 420)
                        .padding(.vertical, 8)
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
                    // Affichage conditionnel selon la planification
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
                let pot = viewModel.totalPot
                viewModel.drawResult = (loser, pot)
                viewModel.setLoserAndSaveHistory(loserName: loser.name)
                MissionService.shared.removeMission(viewModel.mission)
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
    ParticipationView(mission: MissionModel(id: UUID(), name: "Courses", code: "X4E2LQ", inviteCode: "abcd", loserName: nil, isPending: false, minAmount: 1), path: $path)
} 
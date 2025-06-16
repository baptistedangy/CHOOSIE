import SwiftUI

struct ParticipationView: View {
    @StateObject private var viewModel: ParticipationViewModel
    @Binding var path: NavigationPath
    @State private var showDrawResult = false
    @State private var showSlotMachine = false
    @State private var slotLoserIndex: Int? = nil

    init(mission: MissionModel, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: ParticipationViewModel(mission: mission))
        self._path = path
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(viewModel.mission.name)
                .font(.title)
                .fontWeight(.bold)
            Text("Montant total : \(viewModel.mission.totalAmount.stringValue) €")
            Text("Nombre de participants : \(viewModel.mission.participantCount)")
            Text("À payer : \(viewModel.amountPerParticipant.stringValue) €")
                .font(.headline)
                .padding(.bottom)
            if !viewModel.hasPaid {
                Button(action: {
                    viewModel.pay()
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
            if let result = viewModel.drawResult {
                DrawResultView(
                    viewModel: DrawResultViewModel(winnerName: result.winner.name, amountWon: result.amount),
                    path: $path
                )
            }
        }
        .padding()
        .sheet(isPresented: $showSlotMachine, onDismiss: {
            if let idx = slotLoserIndex {
                let loser = viewModel.participants[idx]
                viewModel.drawResult = (loser, viewModel.mission.totalAmount)
                viewModel.setLoserAndSaveHistory(loserName: loser.name)
            }
        }) {
            SlotMachineView(participants: viewModel.participants.map { $0.name }) { loserIdx in
                slotLoserIndex = loserIdx
                showSlotMachine = false
            }
        }
    }
}

#Preview {
    @State var path = NavigationPath()
    ParticipationView(mission: MissionModel(name: "Courses", totalAmount: 40, participantCount: 4, code: "X4E2LQ", inviteCode: "abcd"), path: $path)
} 
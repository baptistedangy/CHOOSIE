import SwiftUI

struct ParticipationView: View {
    @StateObject private var viewModel: ParticipationViewModel
    @Binding var path: NavigationPath
    @State private var showDrawResult = false

    init(task: TaskModel, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: ParticipationViewModel(task: task))
        self._path = path
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(viewModel.task.name)
                .font(.title)
                .fontWeight(.bold)
            Text("Montant total : \(viewModel.task.totalAmount.stringValue) €")
            Text("Nombre de participants : \(viewModel.task.participantCount)")
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
            if viewModel.allPaid {
                Button(action: {
                    viewModel.drawWinner()
                    showDrawResult = true
                }) {
                    Text("Tirage au sort")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            NavigationLink(
                destination: Group {
                    if let result = viewModel.drawResult {
                        DrawResultView(
                            viewModel: DrawResultViewModel(winnerName: result.winner.name, amountWon: result.amount),
                            path: $path
                        )
                    } else {
                        EmptyView()
                    }
                },
                isActive: $showDrawResult
            ) {
                EmptyView()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    ParticipationView(task: TaskModel(name: "Courses", totalAmount: 40, participantCount: 4, code: "X4E2LQ"), path: $path)
} 
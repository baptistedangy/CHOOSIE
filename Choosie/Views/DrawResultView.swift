import SwiftUI

struct DrawResultView: View {
    @ObservedObject var viewModel: DrawResultViewModel
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("🎉 Gagnant du tirage 🎉")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.choosieViolet)
            Text(viewModel.winnerName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.choosieTurquoise)
            Text("Montant gagné : \(viewModel.amountWon.stringValue) €")
                .font(.title2)
                .padding(.top)
                .foregroundColor(.choosieViolet)
            Spacer()
            Button(action: {
                path = NavigationPath()
            }) {
                Text("Retour à l'accueil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.choosieTurquoise)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
        .background(Color.choosieLightBackground)
    }
}

#Preview("Résultat du tirage") {
    NavigationStack {
        DrawResultView(
            viewModel: DrawResultViewModel(winnerName: "Moi", amountWon: 40),
            path: .constant(NavigationPath())
        )
    }
} 
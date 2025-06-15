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
            Text(viewModel.winnerName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
            Text("Montant gagné : \(viewModel.amountWon.stringValue) €")
                .font(.title2)
                .padding(.top)
            Spacer()
            Button(action: {
                path = NavigationPath()
            }) {
                Text("Retour à l'accueil")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    DrawResultView(viewModel: DrawResultViewModel(winnerName: "Moi", amountWon: 40), path: $path)
} 
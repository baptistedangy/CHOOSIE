import SwiftUI

struct JoinMissionView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = JoinMissionViewModel()
    @State private var navigateToParticipation = false

    var body: some View {
        ZStack {
            Color.choosieBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Rejoindre un Jackpot")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieTurquoise)
                Text("Entre le code du Jackpot pour participer !")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                TextField("Code du Jackpot", text: $viewModel.code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 220)
                    .multilineTextAlignment(.center)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, -12)
                }
                Button(action: {
                    if viewModel.joinMission() {
                        navigateToParticipation = true
                    }
                }) {
                    Text("Rejoindre")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canJoin ? Color.choosieTurquoise : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(!viewModel.canJoin)
                .frame(maxWidth: 220)
                NavigationLink(
                    destination: Group {
                        if let mission = viewModel.foundMission {
                            ParticipationView(mission: mission, path: $path)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $navigateToParticipation
                ) {
                    EmptyView()
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    @State var path = NavigationPath()
    JoinMissionView(path: $path)
} 
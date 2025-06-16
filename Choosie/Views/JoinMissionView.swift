import SwiftUI

struct JoinMissionView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = JoinMissionViewModel()
    @State private var navigateToParticipation = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Rejoindre une mission")
                .font(.title)
                .fontWeight(.semibold)
            TextField("Code de la mission", text: $viewModel.code)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 200)
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Button(action: {
                if viewModel.joinMission() {
                    navigateToParticipation = true
                }
            }) {
                Text("Rejoindre")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canJoin ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canJoin)
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

#Preview {
    @State var path = NavigationPath()
    return JoinMissionView(path: $path)
} 
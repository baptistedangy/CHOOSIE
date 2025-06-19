import SwiftUI

struct JoinMissionView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = JoinMissionViewModel()
    
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
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .background(.ultraThinMaterial)
                        .blur(radius: 0.5)
                        .shadow(color: Color.white.opacity(0.10), radius: 8, x: 0, y: 2)
                    HStack {
                        Image(systemName: "key")
                            .foregroundColor(.white.opacity(0.5))
                        TextField("Code du Jackpot", text: $viewModel.code)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 220)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, -12)
                }
                
                Button(action: {
                    if viewModel.joinMission() {
                        if let mission = viewModel.foundMission {
                            path.append(mission)
                        }
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
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Rejoindre un Jackpot") {
    NavigationStack {
        JoinMissionView(path: .constant(NavigationPath()))
    }
} 
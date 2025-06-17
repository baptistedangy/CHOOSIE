import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.choosieLila, .choosieTurquoise, .choosieOrange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()
                MascotView(mood: "👋")
                Text("Bienvenue sur Choosie !")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 4)
                    .padding(.bottom, 8)
                Text("Joue, partage, et tire au sort des missions fun entre amis !")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)

                VStack(spacing: 24) {
                    CardButton(
                        icon: "🎲",
                        title: "Créer une mission",
                        subtitle: "Lance un nouveau défi !",
                        color: .choosieLila
                    ) {
                        path.append("create")
                    }
                    CardButton(
                        icon: "🤝",
                        title: "Rejoindre une mission",
                        subtitle: "Entre un code et participe !",
                        color: .choosieTurquoise
                    ) {
                        path.append("join")
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
    }
}

struct MascotView: View {
    let mood: String
    var body: some View {
        Text(mood)
            .font(.system(size: 60))
            .padding(16)
            .background(Color.white.opacity(0.25))
            .clipShape(Circle())
            .shadow(radius: 8)
            .padding(.bottom, 8)
    }
}

#Preview {
    @State var path = NavigationPath()
    HomeView(path: $path)
} 
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
                MesMissionsEnAttenteSection(path: $path)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
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

struct MesMissionsEnAttenteSection: View {
    @ObservedObject private var missionService = MissionService.shared
    @Binding var path: NavigationPath
    let currentUserId = "MOCK_USER_ID"

    var missionsEnAttente: [MissionModel] {
        missionService.missions.filter { mission in
            mission.isPending
        }
    }

    var body: some View {
        if !missionsEnAttente.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mes missions en attente")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                ForEach(missionsEnAttente) { mission in
                    MissionAttenteCard(mission: mission) {
                        path.append("participation_\(mission.code)")
                    }
                }
            }
            .padding(.top, 24)
        }
    }
}

struct MissionAttenteCard: View {
    let mission: MissionModel
    let onTap: () -> Void
    var body: some View {
        HStack(spacing: 16) {
            Text("🎯")
                .font(.system(size: 36))
                .padding(8)
                .background(Color.choosieLila.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(mission.name)
                    .font(.headline)
                Text("Participants : ? / ? payé(s)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onTap) {
                Text("Revenir à la mission")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.choosieTurquoise.opacity(0.18))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.choosieCard)
        .cornerRadius(18)
        .shadow(color: Color.choosieLila.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    @State var path = NavigationPath()
    HomeView(path: $path)
} 
import SwiftUI

struct ContentView: View {
    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "create":
                        CreateMissionView(path: $path)
                    case "join":
                        JoinMissionView(path: $path)
                    default:
                        EmptyView()
                    }
                }
                .navigationDestination(for: MissionModel.self) { mission in
                    ParticipationView(mission: mission, path: $path)
                }
        }
    }
}

#Preview {
    ContentView()
} 
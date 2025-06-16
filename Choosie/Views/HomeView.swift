import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Choosie")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            NavigationLink(destination: CreateMissionView(path: $path)) {
                Text("Créer une mission")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            NavigationLink(destination: JoinMissionView(path: $path)) {
                Text("Rejoindre une mission")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
            NavigationLink(destination: MissionHistoryView()) {
                Text("Historique")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    return HomeView(path: $path)
} 
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
            NavigationLink(destination: CreateTaskView(path: $path)) {
                Text("Créer une tâche")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            NavigationLink(destination: JoinTaskView(path: $path)) {
                Text("Rejoindre une tâche")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
            NavigationLink(destination: TaskHistoryView()) {
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
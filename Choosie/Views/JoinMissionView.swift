import SwiftUI

struct JoinMissionView: View {
    @Binding var path: NavigationPath
    var body: some View {
        ZStack {
            Color.choosieBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Rejoindre une mission")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieTurquoise)
                Text("Entre le code de la mission pour participer !")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
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
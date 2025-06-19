import SwiftUI

struct UserSetupView: View {
    @Binding var path: NavigationPath
    @State private var name: String = ""
    @State private var navigateToHome = false
    @ObservedObject private var userManager = UserManager.shared
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Bienvenue sur Potpotes !")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Quel est votre prénom ou pseudo ?")
                .font(.title2)
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .background(.ultraThinMaterial)
                    .blur(radius: 0.5)
                    .shadow(color: Color.white.opacity(0.10), radius: 8, x: 0, y: 2)
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.white.opacity(0.5))
                    TextField("Votre nom", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 250)
#if os(iOS)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
#endif
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
            }
            Button(action: {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    userManager.setDisplayName(trimmed)
                    navigateToHome = true
                }
            }) {
                Text("Continuer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            NavigationLink(destination: HomeView(path: $path), isActive: $navigateToHome) {
                EmptyView()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var path = NavigationPath()
    return UserSetupView(path: $path)
} 
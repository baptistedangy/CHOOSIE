import SwiftUI

struct UserSetupView: View {
    @Binding var path: NavigationPath
    @State private var username = ""
    @State private var errorMessage: String?
    @StateObject private var userManager = UserManager.shared
    
    var body: some View {
        ZStack {
            Color.choosieBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Bienvenue sur Choosie !")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieTurquoise)
                
                Text("Comment souhaites-tu être appelé ?")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .background(.ultraThinMaterial)
                        .blur(radius: 0.5)
                        .shadow(color: Color.white.opacity(0.10), radius: 8, x: 0, y: 2)
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.white.opacity(0.5))
                        TextField("Ton pseudo", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 220)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    if username.isEmpty {
                        errorMessage = "Le pseudo ne peut pas être vide"
                        return
                    }
                    userManager.setDisplayName(username)
                    path.append(AppRoute.home)
                }) {
                    Text("Continuer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(username.isEmpty ? Color.gray.opacity(0.3) : Color.choosieTurquoise)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(username.isEmpty)
                .frame(maxWidth: 220)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview("Configuration utilisateur") {
    NavigationStack {
        UserSetupView(path: .constant(NavigationPath()))
    }
} 
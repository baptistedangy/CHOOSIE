import SwiftUI

struct CardButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 20) {
                Text(icon)
                    .font(.system(size: 44))
                    .padding(16)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(Color.choosieCard)
            .cornerRadius(24)
            .shadow(color: color.opacity(0.18), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CardButton(icon: "🎲", title: "Créer une mission", subtitle: "Lance un défi !", color: .choosieLila) {}
} 
import SwiftUI

struct CreateMissionView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = CreateMissionViewModel()
    @State private var navigateToShare = false
    @State private var selectedIndex: Int = -1
    @State private var customMissionName: String = ""
    @State private var selectedAmountIndex: Int = -1
    @State private var selectedParticipantIndex: Int = -1
    @State private var showCustomParticipantField: Bool = false
    @State private var customParticipantText: String = ""
    @State private var minAmountText: String = ""
    @State private var minAmountError: String? = nil
    @FocusState private var minAmountFieldFocused: Bool
    private var amountOptions: [Int] { Array(1...1000) + [-1] }

    struct MissionSuggestion: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let icon: String
    }

    let suggestions: [MissionSuggestion] = [
        .init(name: "Jackpot courses !", icon: "🛒"),
        .init(name: "Jackpot cadeau surprise 🎉", icon: "🎁"),
        .init(name: "Jackpot express", icon: "📦"),
        .init(name: "Soirée entre potes 🍻", icon: "🍻"),
        .init(name: "Régalons-nous !", icon: "🍔"),
        .init(name: "Jackpot de printemps", icon: "🧹"),
        .init(name: "Jackpot aventure", icon: "✈️"),
        .init(name: "Jackpot anniversaire !", icon: "🎂"),
        .init(name: "Autre...", icon: "")
    ]

    var body: some View {
        ZStack {
            Color.choosieBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Créer un Jackpot")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieLila)
                    .padding(.top, 16)

                VStack(spacing: 20) {
                    // Section défi libre + suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choisissez un défi")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.choosieLila)
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.18))
                                .background(.ultraThinMaterial)
                                .blur(radius: 0.5)
                                .shadow(color: Color.white.opacity(0.10), radius: 8, x: 0, y: 2)
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.white.opacity(0.5))
                                TextField("Décris ton défi (ex : 🍕 Pizza du vendredi, 🎁 Cadeau pour Léa...)", text: $customMissionName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: customMissionName) { newValue in
                                        viewModel.missionName = newValue
                                    }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                        }
                        // Suggestions
                        HStack(spacing: 10) {
                            ForEach(["🍕 Pizza party", "🍻 Première tournée", "🎁 Cadeau commun", "🍣 Déj entre collègues", "🚖 Chauffeur désigné"], id: \.self) { suggestion in
                                Button(action: {
                                    customMissionName = suggestion
                                    viewModel.missionName = suggestion
                                }) {
                                    Text(suggestion)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.choosieLila.opacity(0.12))
                                        .foregroundColor(.choosieLila)
                                        .cornerRadius(16)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color.choosieCard)
                    .cornerRadius(20)
                    .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)

                    // Section montant minimum
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quel est le montant minimum que chaque participant devra miser ?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.choosieLila)
                        HStack(spacing: 0) {
                            TextField("0.00 €", text: $minAmountText)
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(Color.choosieLila.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .frame(minWidth: 80, maxWidth: 120)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 8)
                                .focused($minAmountFieldFocused)
                                .animation(.easeOut(duration: 0.22), value: minAmountFieldFocused)
#if os(iOS)
                                .keyboardType(.decimalPad)
#endif
                            Text(" €")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        .frame(maxWidth: 180)
                        // Suggestions rapides
                        HStack(spacing: 10) {
                            ForEach([
                                ("😌", "5"),
                                ("😅", "10"),
                                ("🤑", "20"),
                                ("🤯", "50"),
                                ("💸", "100")
                            ], id: \ .1) { emoji, value in
                                Button(action: {
                                    minAmountText = value
                                    if let v = Double(value) { viewModel.minAmount = v }
                                    minAmountError = nil
                                }) {
                                    HStack(spacing: 4) {
                                        Text(emoji)
                                        Text("\(value) €")
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.choosieLila.opacity(0.12))
                                    .foregroundColor(.choosieLila)
                                    .cornerRadius(16)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        if let error = minAmountError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        Text("Chaque participant devra au moins miser ce montant pour rejoindre le Jackpot.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                    .padding()
                    .background(Color.choosieCard)
                    .cornerRadius(20)
                    .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)
                }

                Button(action: {
                    viewModel.createJackpot()
                    navigateToShare = true
                }) {
                    Text("Créer")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canCreateJackpot ? Color.choosieLila : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.choosieLila.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .disabled(!viewModel.canCreateJackpot)
                .padding(.horizontal, 8)
                NavigationLink(destination: ShareView(mission: viewModel.lastCreatedMission, code: viewModel.generatedCode ?? "", path: $path), isActive: $navigateToShare) {
                    EmptyView()
                }
                Spacer()
            }
            .padding()
            .onAppear {
                selectedIndex = -1
                viewModel.missionName = ""
            }
        }
    }
}

#Preview {
    @State var path = NavigationPath()
    return CreateMissionView(path: $path)
}

// Bouton suggestion de montant
private struct AmountSuggestionButton: View {
    let amount: Int
    let emoji: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                Text("\(amount) €")
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

private struct ParticipantOption: Hashable {
    let value: Int
    let label: String
}

private var participantOptions: [ParticipantOption] {
    [
        .init(value: 2, label: "Duel ⚔️"),
        .init(value: 3, label: "Trio 👨‍👩‍👧"),
        .init(value: 4, label: "Quatuor 🎶"),
        .init(value: 5, label: "Équipe de choc 💪"),
        .init(value: 6, label: "Bande de six 😎"),
        .init(value: 7, label: "Sept fantastiques 🕺"),
        .init(value: 8, label: "Octuor 🥳"),
        .init(value: 9, label: "Neuf aventuriers 🧭"),
        .init(value: 10, label: "Dream team 🔥")
    ]
} 
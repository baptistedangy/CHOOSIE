import SwiftUI

struct CreateMissionView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = CreateMissionViewModel()
    @State private var selectedIndex: Int = -1
    @State private var customMissionName: String = ""
    @State private var selectedAmountIndex: Int = -1
    @State private var selectedParticipantIndex: Int = -1
    @State private var showCustomParticipantField: Bool = false
    @State private var customParticipantText: String = ""
    @State private var minAmountText: String = ""
    @State private var minAmountError: String? = nil
    @FocusState private var minAmountFieldFocused: Bool

    // Constantes pour le layout
    private let horizontalPadding: CGFloat = 16
    private let verticalSpacing: CGFloat = 24
    private let cornerRadius: CGFloat = 20

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
            Color.choosieLightBackground.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: verticalSpacing) {
                    Text("Créer un Jackpot")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.choosieViolet)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Section défi
                    missionSection
                        .padding(.horizontal, horizontalPadding)
                    
                    // Section montant
                    amountSection
                        .padding(.horizontal, horizontalPadding)

                    // Bouton Créer
                    createButton
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationDestination(for: MissionModel.self) { mission in
            ShareView(mission: mission, code: mission.inviteCode, path: $path)
        }
        .onChange(of: minAmountText) { _, newValue in
            if let amount = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                viewModel.minAmount = amount
                minAmountError = nil
            } else {
                minAmountError = "Veuillez entrer un montant valide"
            }
        }
    }

    // MARK: - Sections
    private var missionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choisissez un défi")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.choosieLila)
            
            // Champ de saisie
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.choosieLila.opacity(0.5))
                    TextField("Décris ton défi (ex : 🍕 Pizza du vendredi...)", text: $customMissionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: customMissionName) { _, newValue in
                            viewModel.missionName = newValue
                        }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            
            // Suggestions scrollables
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["🍕 Pizza party", "🍻 Première tournée", "🎁 Cadeau commun", "🍣 Déj entre collègues", "🚖 Chauffeur désigné"], id: \.self) { suggestion in
                        Button(action: {
                            customMissionName = suggestion
                            viewModel.missionName = suggestion
                        }) {
                            Text(suggestion)
                                .lineLimit(1)
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
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.choosieCardLight)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quel est le montant minimum que chaque participant devra miser ?")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.choosieLila)
                .fixedSize(horizontal: false, vertical: true)
            
            // Champ de montant
            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 4) {
                    TextField("0.00", text: $minAmountText)
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundColor(Color.choosieLila.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 80, maxWidth: 120)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .focused($minAmountFieldFocused)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    
                    Text("€")
                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .background(Color.white)
                .cornerRadius(12)
                Spacer()
            }
            
            // Suggestions de montants scrollables
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([
                        ("😌", "5"),
                        ("😅", "10"),
                        ("🤑", "20"),
                        ("🤯", "50"),
                        ("💸", "100")
                    ], id: \.1) { emoji, value in
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
                .padding(.vertical, 4)
            }
            
            if let error = minAmountError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.choosieCardLight)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var createButton: some View {
        Button(action: {
            guard !viewModel.missionName.isEmpty else {
                // Ajouter une animation de shake ou un feedback visuel
                return
            }
            
            guard let amount = Double(minAmountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                minAmountError = "Veuillez entrer un montant valide"
                return
            }
            
            viewModel.minAmount = amount
            if let mission = viewModel.createJackpot() {
                path.append(mission)
            }
        }) {
            Text("Créer")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(!viewModel.missionName.isEmpty && minAmountText.count > 0 ? Color.choosieLila : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.choosieLila.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.missionName.isEmpty || minAmountText.isEmpty)
    }
}

#Preview("Créer un Jackpot") {
    NavigationStack {
        CreateMissionView(path: .constant(NavigationPath()))
    }
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
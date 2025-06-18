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
    @State private var tirageOption: String = "now"
    @State private var scheduledDate: Date = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
    private var amountOptions: [Int] { Array(1...1000) + [-1] }

    struct MissionSuggestion: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let icon: String
    }

    let suggestions: [MissionSuggestion] = [
        .init(name: "Go faire les courses !", icon: "🛒"),
        .init(name: "Opération cadeau surprise 🎉", icon: "🎁"),
        .init(name: "Mission colis express", icon: "📦"),
        .init(name: "Soirée entre potes 🍻", icon: "🍻"),
        .init(name: "Régalons-nous !", icon: "🍔"),
        .init(name: "Grand ménage de printemps", icon: "🧹"),
        .init(name: "Aventure à l'autre bout du monde", icon: "✈️"),
        .init(name: "Anniv' de folie !", icon: "🎂"),
        .init(name: "Autre...", icon: "")
    ]

    var body: some View {
        ZStack {
            Color.choosieBackground.ignoresSafeArea()
            VStack(spacing: 32) {
                Text("Créer une mission")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieLila)
                    .padding(.top, 16)

                VStack(spacing: 20) {
                    HStack {
                        Text("📝")
                            .font(.system(size: 32))
                            .padding(.trailing, 8)
                        VStack(alignment: .leading) {
                            Text("Choisissez une mission")
                                .font(.headline)
                            Picker("", selection: $selectedIndex) {
                                Text("Choisis la mission…").tag(-1)
                                ForEach(0..<suggestions.count, id: \ .self) { idx in
                                    Text("\(suggestions[idx].icon)  \(suggestions[idx].name)")
                                        .tag(idx)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedIndex) { newValue in
                                if newValue == -1 {
                                    viewModel.missionName = ""
                                } else if suggestions[newValue].name == "Autre..." {
                                    viewModel.missionName = customMissionName
                                } else {
                                    viewModel.missionName = suggestions[newValue].name
                                }
                            }
                            if selectedIndex != -1 && suggestions[selectedIndex].name == "Autre..." {
                                TextField("Nom de la mission", text: $customMissionName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: customMissionName) { newValue in
                                        if selectedIndex != -1 && suggestions[selectedIndex].name == "Autre..." {
                                            viewModel.missionName = newValue
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color.choosieCard)
                    .cornerRadius(20)
                    .shadow(color: Color.choosieLila.opacity(0.08), radius: 8, x: 0, y: 4)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quand doit avoir lieu le tirage ?")
                        .font(.headline)
                    HStack(spacing: 24) {
                        Button(action: { tirageOption = "now" }) {
                            HStack {
                                Image(systemName: tirageOption == "now" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.choosieLila)
                                Text("Maintenant")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: { tirageOption = "later" }) {
                            HStack {
                                Image(systemName: tirageOption == "later" ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.choosieLila)
                                Text("Plus tard")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    if tirageOption == "later" {
                        DatePicker("Date et heure du tirage", selection: $scheduledDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(.leading, 8)
                    }
                }
                .padding()
                .background(Color.choosieCard)
                .cornerRadius(16)
                .shadow(color: Color.choosieLila.opacity(0.08), radius: 4, x: 0, y: 2)

                Button(action: {
                    if viewModel.createMission(drawDate: tirageOption == "later" ? scheduledDate : nil) {
                        navigateToShare = true
                    }
                }) {
                    Text("Créer")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canCreate ? Color.choosieLila : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.choosieLila.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .disabled(!viewModel.canCreate || selectedIndex == -1)
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
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
        VStack(spacing: 24) {
            Text("Créer une mission")
                .font(.title)
                .fontWeight(.semibold)
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
            Text("Montant total")
                .font(.headline)
            Picker("", selection: $selectedAmountIndex) {
                Text("Renseigne le montant…").tag(-1)
                ForEach(0..<amountOptions.count, id: \ .self) { idx in
                    if idx < amountOptions.count - 1 {
                        Text("\(amountOptions[idx]) €").tag(idx)
                    } else {
                        Text("Autre montant...").tag(idx)
                    }
                }
            }
            .onChange(of: selectedAmountIndex) { newValue in
                if newValue == -1 {
                    viewModel.isCustomAmount = false
                    viewModel.totalAmount = 0
                } else if newValue < amountOptions.count - 1 {
                    viewModel.isCustomAmount = false
                    viewModel.totalAmount = Decimal(amountOptions[newValue])
                } else {
                    viewModel.isCustomAmount = true
                    viewModel.totalAmount = 0
                }
            }
            if viewModel.isCustomAmount {
                #if os(iOS)
                TextField("Autre montant…", text: Binding(
                    get: { viewModel.totalAmount == 0 ? "" : String(format: "%.2f", NSDecimalNumber(decimal: viewModel.totalAmount).doubleValue) },
                    set: { newValue in
                        if let value = Decimal(string: newValue.replacingOccurrences(of: ",", with: ".")) {
                            viewModel.totalAmount = value
                        } else {
                            viewModel.totalAmount = 0
                        }
                    })
                )
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                TextField("Autre montant…", text: Binding(
                    get: { viewModel.totalAmount == 0 ? "" : String(format: "%.2f", NSDecimalNumber(decimal: viewModel.totalAmount).doubleValue) },
                    set: { newValue in
                        if let value = Decimal(string: newValue.replacingOccurrences(of: ",", with: ".")) {
                            viewModel.totalAmount = value
                        } else {
                            viewModel.totalAmount = 0
                        }
                    })
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
            }
            Text("Nombre de participants")
                .font(.headline)
            Picker("", selection: $selectedParticipantIndex) {
                Text("Choisis le nombre de participants…").tag(-1)
                ForEach(0..<participantOptions.count, id: \ .self) { idx in
                    Text("\(participantOptions[idx].value) - \(participantOptions[idx].label)").tag(idx)
                }
                Text("Autre...").tag(participantOptions.count)
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedParticipantIndex) { newValue in
                if newValue == -1 {
                    viewModel.participantCount = 0
                    showCustomParticipantField = false
                } else if newValue < participantOptions.count {
                    viewModel.participantCount = participantOptions[newValue].value
                    showCustomParticipantField = false
                } else {
                    showCustomParticipantField = true
                }
            }
            if showCustomParticipantField {
                #if os(iOS)
                TextField("Nombre de participants (2-20)", text: $customParticipantText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: customParticipantText) { newValue in
                        if let val = Int(newValue), val >= 2, val <= 20 {
                            viewModel.participantCount = val
                        }
                    }
                #else
                TextField("Nombre de participants (2-20)", text: $customParticipantText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: customParticipantText) { newValue in
                        if let val = Int(newValue), val >= 2, val <= 20 {
                            viewModel.participantCount = val
                        }
                    }
                #endif
            }
            Button(action: {
                if viewModel.createMission() {
                    navigateToShare = true
                }
            }) {
                Text("Créer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canCreate ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canCreate || selectedIndex == -1 || selectedAmountIndex == -1 || selectedParticipantIndex == -1)
            NavigationLink(destination: ShareView(code: viewModel.generatedCode ?? "", path: $path), isActive: $navigateToShare) {
                EmptyView()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            selectedIndex = -1
            viewModel.missionName = ""
            selectedAmountIndex = -1
            viewModel.totalAmount = 0
            selectedParticipantIndex = -1
            viewModel.participantCount = 0
            showCustomParticipantField = false
            customParticipantText = ""
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
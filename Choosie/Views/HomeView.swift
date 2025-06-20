import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @ObservedObject private var userManager = UserManager.shared
    @State private var showProfile = false
    @State private var showProfileSetup = false

    var body: some View {
        ZStack {
            Color.choosieLightBackground
                .ignoresSafeArea()

            VStack(spacing: 36) {
                HStack {
                    Spacer()
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 32))
                            .foregroundColor(.choosieViolet)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .choosieViolet.opacity(0.12), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.top, 12)
                MascotView(mood: "🎉")
                Text("Bienvenue sur Potpotes !")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.choosieViolet)
                    .shadow(radius: 2)
                    .padding(.bottom, 4)
                Text("Payer c'est jouer!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.choosieTurquoise)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)
                VStack(spacing: 24) {
                    CardButton(
                        icon: "🎲",
                        title: "Créer un Jackpot",
                        subtitle: "Lance un nouveau défi !",
                        color: .choosieViolet
                    ) {
                        path.append("create")
                    }
                    CardButton(
                        icon: "🤝",
                        title: "Rejoindre un Jackpot",
                        subtitle: "Entre un code et participe !",
                        color: .choosieTurquoise
                    ) {
                        path.append("join")
                    }
                }
                .padding(.horizontal, 24)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(showProfile: $showProfile, path: $path)
            }
            .sheet(isPresented: $showProfileSetup) {
                ProfileSetupView(showProfileSetup: $showProfileSetup)
            }
        }
        .onAppear {
            if !userManager.hasProfile {
                showProfileSetup = true
            }
        }
    }
}

struct MascotView: View {
    let mood: String
    var body: some View {
        Text(mood)
            .font(.system(size: 60))
            .padding(16)
            .background(Color.white.opacity(0.25))
            .clipShape(Circle())
            .shadow(radius: 8)
            .padding(.bottom, 8)
    }
}

// Section Mes Jackpots en attente
struct MesJackpotsEnAttenteSection: View {
    @ObservedObject private var missionService = MissionService.shared
    @Binding var path: NavigationPath
    @State private var showSheet = false
    let currentUserId = "MOCK_USER_ID"

    var missionsEnAttente: [MissionModel] {
        missionService.missions.filter { mission in
            mission.createdBy == UserManager.shared.userId && mission.loserName == nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { showSheet = true }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.choosieTurquoise)
                    Text("Voir mes Jackpots en attente")
                        .font(.headline)
                        .foregroundColor(.choosieTurquoise)
                    Spacer()
                    if !missionsEnAttente.isEmpty {
                        Text("\(missionsEnAttente.count)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.choosieTurquoise)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.choosieCardLight.opacity(0.7))
                .cornerRadius(16)
                .shadow(color: Color.choosieTurquoise.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            // Affichage direct de la liste des jackpots en attente (hors feuille)
            if !missionsEnAttente.isEmpty {
                VStack(spacing: 16) {
                    ForEach(missionsEnAttente) { mission in
                        MissionAttenteCard(mission: mission) {
                            path.append(mission)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct MissionAttenteCard: View {
    let mission: MissionModel
    let onTap: () -> Void
    var participantCount: Int = 3 // Dummy data
    @State private var showDeleteAlert = false
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("🎯")
                        .font(.system(size: 28))
                    Text(mission.name)
                        .font(.headline)
                }
                Text("Mise min. : \(String(format: "%.2f", mission.minAmount)) €")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Créé le : \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Participants : \(participantCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing: 10) {
                Button(action: onTap) {
                    Text("Revenir au Jackpot")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.choosieTurquoise.opacity(0.18))
                        .cornerRadius(10)
                }
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Annuler le Jackpot ?"),
                        message: Text("Confirmer l'annulation de ce Jackpot en attente ?"),
                        primaryButton: .destructive(Text("Annuler")) {
                            MissionService.shared.removeMission(mission)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .padding(12)
        .background(Color.choosieCardLight.opacity(0.7))
        .cornerRadius(14)
        .shadow(color: Color.choosieLila.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// Page Historique des Jackpots (version simple)
struct HistoriqueJackpotsPage: View {
    @ObservedObject private var historyManager = MissionHistoryManager.shared
    @ObservedObject private var userManager = UserManager.shared
    @Binding var showHistorique: Bool
    @Binding var path: NavigationPath
    @State private var missionToDelete: CompletedMission? = nil
    @State private var showDeleteAlert = false

    var missions: [CompletedMission] {
        historyManager.missions
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: { showHistorique = false }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Revenir à l'accueil")
                        }
                        .font(.headline)
                        .foregroundColor(.choosieLila)
                        .padding(8)
                        .background(Color.choosieCard)
                        .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding([.top, .horizontal], 16)
                Text("Historique des Jackpots")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                if missions.isEmpty {
                    Spacer()
                    Text("Aucun Jackpot terminé.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(missions) { mission in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mission.missionName)
                                            .font(.headline)
                                        Text("Gagnant : \(mission.winner == userManager.displayName ? "Moi" : mission.winner)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Montant : \(mission.totalAmount, specifier: "%.2f") €")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(mission.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: {
                                        // TODO: Navigation vers la page de détails de la mission
                                    }) {
                                        Text("Détails")
                                            .font(.subheadline)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.choosieLila.opacity(0.15))
                                            .cornerRadius(10)
                                    }
                                    Button(action: {
                                        missionToDelete = mission
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                            .background(Color.red.opacity(0.08))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(8)
                                .background(Color.choosieCardLight.opacity(0.7))
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                Spacer(minLength: 12)
            }
            .background(Color.choosieBackground.ignoresSafeArea())
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Supprimer le Jackpot ?"),
                    message: Text("Confirmer la suppression de ce Jackpot de l'historique ?"),
                    primaryButton: .destructive(Text("Supprimer")) {
                        if let mission = missionToDelete {
                            historyManager.removeMission(mission)
                        }
                        missionToDelete = nil
                    },
                    secondaryButton: .cancel(Text("Annuler")) {
                        missionToDelete = nil
                    }
                )
            }
        }
    }
}

// Clé de navigation pour ParticipationView
struct ParticipationNavigationKey: Hashable {
    let mission: MissionModel
}

// Vue de création du profil utilisateur
struct ProfileSetupView: View {
    @ObservedObject private var userManager = UserManager.shared
    @Binding var showProfileSetup: Bool
    @State private var pseudo: String = ""
    @State private var emoji: String = "😀"
    @State private var showError = false
    let emojis = ["😀", "😎", "🥳", "🤩", "🦄", "🐱", "🐶", "🦊", "🐼", "🐸", "🐵", "🦁", "🐯", "🐰", "🐻", "🐨", "🐷", "🐮", "🐔", "🐧", "🐦", "🐤", "🐙", "🦋", "🐢", "🐬", "🦖", "🦕", "🦩", "🦚", "🦜", "🦢", "🦩", "🦔", "🦦", "🦥", "🦨", "🦘", "🦡", "🦃", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞", "🐜", "🦗", "🕷", "🦂", "🦟", "🦠"]

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Créer mon profil")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 24)
                VStack(spacing: 20) {
                    TextField("Choisis un pseudo", text: $pseudo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 32)
                    Text("Choisis ton emoji")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojis, id: \.self) { e in
                                Text(e)
                                    .font(.system(size: 36))
                                    .padding(8)
                                    .background(emoji == e ? Color.choosieLila.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture { emoji = e }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                if showError {
                    Text("Merci de renseigner un pseudo et un emoji.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Button(action: {
                    if pseudo.trimmingCharacters(in: .whitespaces).isEmpty || emoji.isEmpty {
                        showError = true
                    } else {
                        userManager.saveProfile(pseudo: pseudo, emoji: emoji)
                        showProfileSetup = false
                    }
                }) {
                    Text("Valider")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.choosieLila)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 32)
                }
                Spacer()
            }
        }
    }
}

// Vue Profil utilisateur
struct ProfileView: View {
    @ObservedObject private var userManager = UserManager.shared
    @Binding var showProfile: Bool
    @Binding var path: NavigationPath
    @State private var showPending = true
    @State private var showHistory = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Button(action: { showProfile = false }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Retour à l'accueil")
                            }
                            .font(.headline)
                            .foregroundColor(.choosieLila)
                            .padding(8)
                            .background(Color.choosieCard)
                            .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    VStack(spacing: 8) {
                        Text(userManager.emoji)
                            .font(.system(size: 60))
                            .padding(8)
                        Text(userManager.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 16)
                    // Section Jackpots en attente
                    SectionHeader(title: "Mes Jackpots en attente", isExpanded: $showPending)
                    if showPending {
                        MesJackpotsEnAttenteSection(path: $path)
                            .padding(.horizontal, 8)
                    }
                    // Section historique
                    SectionHeader(title: "Historique des Jackpots", isExpanded: $showHistory)
                    if showHistory {
                        HistoryMissionsListSection(path: $path)
                            .padding(.horizontal, 8)
                    }
                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    @Binding var isExpanded: Bool
    var body: some View {
        Button(action: { isExpanded.toggle() }) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.choosieCardLight.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HistoryMissionsListSection: View {
    @ObservedObject private var historyManager = MissionHistoryManager.shared
    @ObservedObject private var userManager = UserManager.shared
    @Binding var path: NavigationPath
    var missions: [CompletedMission] {
        historyManager.missions
    }
    var body: some View {
        if missions.isEmpty {
            Text("Aucun Jackpot terminé.")
                .foregroundColor(.gray)
                .padding(.vertical, 8)
        } else {
            VStack(spacing: 12) {
                ForEach(missions) { mission in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mission.missionName)
                                .font(.headline)
                            Text("Gagnant : \(mission.winner == userManager.displayName ? "Moi" : mission.winner)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Montant : \(mission.totalAmount, specifier: "%.2f") €")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(mission.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            // TODO: Navigation vers la page de détails de la mission
                        }) {
                            Text("Détails")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.choosieLila.opacity(0.15))
                                .cornerRadius(10)
                        }
                        Button(action: {
                            historyManager.removeMission(mission)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.red.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(8)
                    .background(Color.choosieCardLight.opacity(0.7))
                    .cornerRadius(14)
                }
            }
        }
    }
}

#Preview("Accueil") {
    NavigationStack {
        HomeView(path: .constant(NavigationPath()))
    }
} 
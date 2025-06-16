import SwiftUI

struct MissionHistoryView: View {
    @ObservedObject private var historyManager = MissionHistoryManager.shared
    @ObservedObject private var userManager = UserManager.shared
    
    var filteredMissions: [CompletedMission] {
        historyManager.missions.filter { mission in
            mission.createdBy.uuidString == userManager.userId ||
            mission.participants.contains(userManager.displayName) ||
            mission.winner == userManager.displayName
        }
    }
    
    var body: some View {
        VStack {
            Text("Historique des missions")
                .font(.largeTitle)
                .padding(.top)
            if filteredMissions.isEmpty {
                Spacer()
                Text("Aucune mission terminée.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(filteredMissions) { mission in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(mission.missionName)
                                .font(.headline)
                            Spacer()
                            Text("\(mission.totalAmount, specifier: "%.2f") €")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Gagnant : \(mission.winner)")
                                .font(.subheadline)
                            Spacer()
                            Text(mission.date, style: .date)
                                .font(.caption)
                        }
                        Text(role(for: mission))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func role(for mission: CompletedMission) -> String {
        if mission.createdBy.uuidString == userManager.userId {
            return "Créateur"
        } else if mission.winner == userManager.displayName {
            return "Gagnant"
        } else if mission.participants.contains(userManager.displayName) {
            return "Participant"
        } else {
            return "-"
        }
    }
}

#Preview {
    MissionHistoryView()
} 
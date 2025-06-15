import SwiftUI

struct TaskHistoryView: View {
    @ObservedObject private var historyManager = TaskHistoryManager.shared
    @ObservedObject private var userManager = UserManager.shared
    
    var filteredTasks: [CompletedTask] {
        historyManager.tasks.filter { task in
            task.createdBy.uuidString == userManager.userId ||
            task.participants.contains(userManager.displayName) ||
            task.winner == userManager.displayName
        }
    }
    
    var body: some View {
        VStack {
            Text("Historique des tâches")
                .font(.largeTitle)
                .padding(.top)
            if filteredTasks.isEmpty {
                Spacer()
                Text("Aucune tâche terminée.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(filteredTasks) { task in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(task.taskName)
                                .font(.headline)
                            Spacer()
                            Text("\(task.totalAmount, specifier: "%.2f") €")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Gagnant : \(task.winner)")
                                .font(.subheadline)
                            Spacer()
                            Text(task.date, style: .date)
                                .font(.caption)
                        }
                        Text(role(for: task))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func role(for task: CompletedTask) -> String {
        if task.createdBy.uuidString == userManager.userId {
            return "Créateur"
        } else if task.winner == userManager.displayName {
            return "Gagnant"
        } else if task.participants.contains(userManager.displayName) {
            return "Participant"
        } else {
            return "-"
        }
    }
}

#Preview {
    TaskHistoryView()
} 
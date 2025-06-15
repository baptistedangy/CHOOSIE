import Foundation

class TaskHistoryManager: ObservableObject {
    static let shared = TaskHistoryManager()
    private let storageKey = "completedTasks"
    @Published private(set) var tasks: [CompletedTask] = []
    
    private init() {
        load()
        if tasks.isEmpty {
            addSampleTasks()
        }
    }
    
    func addTask(_ task: CompletedTask) {
        tasks.append(task)
        save()
    }
    
    func fetchTasks() -> [CompletedTask] {
        tasks
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CompletedTask].self, from: data) {
            self.tasks = decoded
        }
    }
    
    private func addSampleTasks() {
        let userId = UUID(uuidString: UserManager.shared.userId) ?? UUID()
        let now = Date()
        let samples: [CompletedTask] = [
            CompletedTask(
                id: UUID(),
                taskName: "Courses",
                totalAmount: 40.0,
                participants: [UserManager.shared.displayName, "Alex", "Sam"],
                winner: "Alex",
                createdBy: userId,
                date: now.addingTimeInterval(-86400)
            ),
            CompletedTask(
                id: UUID(),
                taskName: "Nettoyage garage",
                totalAmount: 60.0,
                participants: ["Jordan", UserManager.shared.displayName, "Charlie"],
                winner: UserManager.shared.displayName,
                createdBy: UUID(),
                date: now.addingTimeInterval(-172800)
            ),
            CompletedTask(
                id: UUID(),
                taskName: "Sortie poubelles",
                totalAmount: 10.0,
                participants: ["Morgan", UserManager.shared.displayName],
                winner: "Morgan",
                createdBy: userId,
                date: now.addingTimeInterval(-259200)
            )
        ]
        self.tasks = samples
        save()
    }
} 
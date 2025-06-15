import Foundation

class TaskService {
    static let shared = TaskService()
    private init() {}

    @Published private(set) var tasks: [TaskModel] = []

    func addTask(_ task: TaskModel) {
        tasks.append(task)
    }

    func getTask(by code: String) -> TaskModel? {
        return tasks.first { $0.code == code }
    }
} 
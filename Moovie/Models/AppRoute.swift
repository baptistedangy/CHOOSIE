import Foundation

enum AppRoute: Hashable {
    case createTask
    case joinTask
    case share(code: String)
    case participation(task: TaskModel)
    case history
} 
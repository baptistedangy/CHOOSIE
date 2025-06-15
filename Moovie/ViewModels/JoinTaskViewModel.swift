import Foundation

class JoinTaskViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var errorMessage: String? = nil
    @Published var foundTask: TaskModel? = nil

    var canJoin: Bool {
        code.count == 6 && code.range(of: "^[A-Z0-9]{6}$", options: .regularExpression) != nil
    }

    func joinTask() -> Bool {
        errorMessage = nil
        guard canJoin else {
            errorMessage = "Le code doit comporter 6 caractères alphanumériques."
            return false
        }
        let uppercasedCode = code.uppercased()
        if let task = TaskService.shared.getTask(by: uppercasedCode) {
            foundTask = task
            return true
        } else {
            errorMessage = "Aucune tâche trouvée pour ce code."
            return false
        }
    }
} 
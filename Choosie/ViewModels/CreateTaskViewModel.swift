import Foundation

class CreateTaskViewModel: ObservableObject {
    @Published var taskName: String = ""
    @Published var totalAmountString: String = ""
    @Published var participantCount: Int = 2
    @Published var generatedCode: String? = nil

    var canCreate: Bool {
        guard !taskName.isEmpty,
              let amount = Decimal(string: totalAmountString),
              amount > 0,
              participantCount >= 2 else { return false }
        return true
    }

    func createTask() -> Bool {
        guard canCreate else { return false }
        let code = Self.generateCode()
        self.generatedCode = code
        let amount = Decimal(string: totalAmountString) ?? 0
        let task = TaskModel(name: taskName, totalAmount: amount, participantCount: participantCount, code: code)
        TaskService.shared.addTask(task)
        return true
    }

    private static func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }
} 
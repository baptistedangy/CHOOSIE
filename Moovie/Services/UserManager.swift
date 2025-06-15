import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    private let userIdKey = "userId"
    private let displayNameKey = "displayName"
    
    @Published var userId: String
    @Published var displayName: String {
        didSet {
            UserDefaults.standard.set(displayName, forKey: displayNameKey)
        }
    }
    
    private init() {
        if let savedId = UserDefaults.standard.string(forKey: userIdKey) {
            self.userId = savedId
        } else {
            let newId = UUID().uuidString
            self.userId = newId
            UserDefaults.standard.set(newId, forKey: userIdKey)
        }
        self.displayName = UserDefaults.standard.string(forKey: displayNameKey) ?? ""
    }
    
    func setDisplayName(_ name: String) {
        self.displayName = name
    }
    
    var isSetupComplete: Bool {
        !displayName.isEmpty
    }
} 
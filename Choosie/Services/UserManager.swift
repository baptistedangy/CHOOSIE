import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    private let userIdKey = "userId"
    private let displayNameKey = "displayName"
    private let pseudoKey = "userPseudo"
    private let emojiKey = "userEmoji"
    
    @Published var userId: String
    @Published var displayName: String {
        didSet {
            UserDefaults.standard.set(displayName, forKey: displayNameKey)
        }
    }
    @Published var emoji: String = ""
    
    private init() {
        if let savedId = UserDefaults.standard.string(forKey: userIdKey) {
            self.userId = savedId
        } else {
            let newId = UUID().uuidString
            self.userId = newId
            UserDefaults.standard.set(newId, forKey: userIdKey)
        }
        self.displayName = UserDefaults.standard.string(forKey: displayNameKey) ?? ""
        loadProfile()
    }
    
    func setDisplayName(_ name: String) {
        self.displayName = name
    }
    
    var isSetupComplete: Bool {
        !displayName.isEmpty
    }
    
    func saveProfile(pseudo: String, emoji: String) {
        self.displayName = pseudo
        self.emoji = emoji
        UserDefaults.standard.set(pseudo, forKey: pseudoKey)
        UserDefaults.standard.set(emoji, forKey: emojiKey)
    }
    
    func loadProfile() {
        if let pseudo = UserDefaults.standard.string(forKey: pseudoKey) {
            self.displayName = pseudo
        }
        if let emoji = UserDefaults.standard.string(forKey: emojiKey) {
            self.emoji = emoji
        }
    }
    
    var hasProfile: Bool {
        !displayName.isEmpty && !emoji.isEmpty
    }
} 
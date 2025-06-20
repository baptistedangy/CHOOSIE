import SwiftUI

extension Color {
    static let choosieLila = Color(red: 162/255, green: 89/255, blue: 255/255)
    static let choosieTurquoise = Color(red: 67/255, green: 230/255, blue: 225/255)
    static let choosieOrange = Color(red: 255/255, green: 184/255, blue: 108/255)
    static let choosieCard = Color(hex: "181818")
    static let choosieBackground = Color(hex: "0F0F0F")
    static let choosieText = Color(hex: "F5F5F5")
    static let choosieGold = Color(hex: "FFD700")
    static let choosieGoldAlt = Color(hex: "F6C94A")
    static let choosieViolet = Color(hex: "A259FF")
    static let choosieRed = Color(hex: "FF4D4D")
    static let choosieGray = Color(hex: "2C2C2C")
    static let choosieLightBackground = Color(hex: "FAFAFF")
    static let choosieCardLight = Color(hex: "F3F6FF")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
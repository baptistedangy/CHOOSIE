import Foundation

enum AppRoute: Hashable {
    case home
    case createMission
    case joinMission
    case share(code: String)
    case participation(mission: MissionModel)
    case history
} 
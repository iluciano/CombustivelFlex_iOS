import SwiftUI

enum AppTab: Hashable {
    case home
    case history
    case stations
    case more

    var title: String {
        switch self {
        case .home: return "Início"
        case .history: return "Histórico"
        case .stations: return "Postos"
        case .more: return "Mais"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .history: return "clock"
        case .stations: return "fuelpump"
        case .more: return "ellipsis.circle"
        }
    }

    var selectedSystemImage: String {
        switch self {
        case .home: return "house.fill"
        case .history: return "clock.fill"
        case .stations: return "fuelpump.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }
}

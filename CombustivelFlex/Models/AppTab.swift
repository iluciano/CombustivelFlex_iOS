import SwiftUI

enum AppTab: Hashable {
    case home
    case stations
    case maintenance
    case more

    var title: String {
        switch self {
        case .home: return "Início"
        case .stations: return "Postos"
        case .maintenance: return "Manutenção"
        case .more: return "Mais"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .stations: return "fuelpump"
        case .maintenance: return "wrench.and.screwdriver"
        case .more: return "ellipsis.circle"
        }
    }

    var selectedSystemImage: String {
        switch self {
        case .home: return "house.fill"
        case .stations: return "fuelpump.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }
}

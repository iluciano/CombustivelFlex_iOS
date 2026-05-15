import Foundation

struct FuelStation: Identifiable {
    let id: String
    let name: String
    let brand: FuelStationBrand
    let latitude: Double
    let longitude: Double
    let regularGasolinePrice: Double
    let additiveGasolinePrice: Double?
    let ethanolPrice: Double?
    let address: String?
    let updatedAt: String?
    var distanceMeters: Double?
}

enum FuelStationBrand: String {
    case ipiranga
    case shell
    case br
    case ale
    case totalenergies
    case unknown

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "ipiranga":
            self = .ipiranga
        case "shell":
            self = .shell
        case "br", "vibra", "petrobras", "petrobras br", "br mania":
            self = .br
        case "ale":
            self = .ale
        case "totalenergies", "total energies":
            self = .totalenergies
        default:
            self = .unknown
        }
    }

    var displayName: String {
        switch self {
        case .ipiranga: return "Ipiranga"
        case .shell: return "Shell"
        case .br: return "BR"
        case .ale: return "ALE"
        case .totalenergies: return "TotalEnergies"
        case .unknown: return "Posto"
        }
    }

    var initials: String {
        switch self {
        case .ipiranga: return "IP"
        case .shell: return "SH"
        case .br: return "BR"
        case .ale: return "AL"
        case .totalenergies: return "TE"
        case .unknown: return "P"
        }
    }

    var logoAssetName: String? {
        switch self {
        case .ipiranga: return "station_ipiranga"
        case .shell: return "station_shell"
        case .br: return "station_br"
        case .ale: return "station_ale"
        case .totalenergies, .unknown: return nil
        }
    }
}

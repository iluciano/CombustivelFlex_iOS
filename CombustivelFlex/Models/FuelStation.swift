import Foundation

struct FuelStation: Identifiable, Codable, Equatable {
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
    let collectionDate: String?
    var distanceMeters: Double?

    static let defaultCollectionDate = "08/05/2026"

    var displayCollectionDate: String {
        guard let collectionDate, !collectionDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Self.defaultCollectionDate
        }

        return collectionDate
    }

    static func == (lhs: FuelStation, rhs: FuelStation) -> Bool {
        lhs.id == rhs.id
    }
}

enum FuelStationBrand: String, Codable {
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

enum FavoriteStationsStore {
    private static let idsKey = "favorite_ids"
    private static let stationKeyPrefix = "posto_"
    private static let defaults = UserDefaults.standard

    static func isFavorite(_ stationID: String) -> Bool {
        favoriteIDs().contains(stationID)
    }

    static func add(_ station: FuelStation) {
        var ids = favoriteIDs()
        guard !ids.contains(station.id) else {
            save(station)
            return
        }

        ids.append(station.id)
        defaults.set(ids, forKey: idsKey)
        save(station)
    }

    static func remove(_ stationID: String) {
        var ids = favoriteIDs()
        ids.removeAll { $0 == stationID }
        defaults.set(ids, forKey: idsKey)
        defaults.removeObject(forKey: stationKey(for: stationID))
    }

    static func favorites() -> [FuelStation] {
        favoriteIDs().compactMap { stationID in
            guard let json = defaults.string(forKey: stationKey(for: stationID)),
                  let data = json.data(using: .utf8),
                  let station = try? JSONDecoder().decode(FuelStation.self, from: data) else {
                return nil
            }

            return station
        }
    }

    private static func favoriteIDs() -> [String] {
        defaults.stringArray(forKey: idsKey) ?? []
    }

    private static func save(_ station: FuelStation) {
        guard let data = try? JSONEncoder().encode(station),
              let json = String(data: data, encoding: .utf8) else {
            return
        }

        defaults.set(json, forKey: stationKey(for: station.id))
    }

    private static func stationKey(for stationID: String) -> String {
        "\(stationKeyPrefix)\(stationID)"
    }
}

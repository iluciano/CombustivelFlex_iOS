import Foundation

struct OilChangeRecord: Codable, Identifiable {
    var id: Double { timestamp }

    var timestamp: Double
    var date: String
    var km: Int
    var nextKm: Int
    var nextDate: String

    var changedEngineOil: Bool
    var changedOilFilter: Bool
    var changedAirFilter: Bool
    var changedFuelFilter: Bool
    var changedCabinFilter: Bool
    var changedBrakeFluid: Bool
    var changedSparkPlugs: Bool

    var oilType: String
    var notes: String
}

enum OilChangeStore {
    private static let key = "oil_change_history"
    private static let maxHistory = 25

    static func getHistory() -> [OilChangeRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([OilChangeRecord].self, from: data) else {
            return []
        }

        return list
    }

    static func save(_ record: OilChangeRecord) {
        var storedRecord = record
        storedRecord.timestamp = Date().timeIntervalSince1970 * 1000

        var history = getHistory()
        history.insert(storedRecord, at: 0)

        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }

        persist(history)
    }

    static func update(_ updated: OilChangeRecord) {
        var history = getHistory()

        if let index = history.firstIndex(where: { $0.timestamp == updated.timestamp }) {
            history[index] = updated
        }

        persist(history)
    }

    static func delete(timestamp: Double) {
        var history = getHistory()
        history.removeAll { $0.timestamp == timestamp }
        persist(history)
    }

    static func getLatest() -> OilChangeRecord? {
        getHistory().first
    }

    private static func persist(_ history: [OilChangeRecord]) {
        guard let data = try? JSONEncoder().encode(history) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

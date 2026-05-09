import Foundation
import Combine

@MainActor
final class HistoryStore: ObservableObject {
    static let maxStoredItems = 25

    @Published private(set) var items: [CalculationHistoryItem]

    private let storageKey = "calculation_history_items"
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.items = Self.loadItems(from: userDefaults, key: storageKey, decoder: decoder)
    }

    func save(_ item: CalculationHistoryItem) {
        items.insert(item, at: 0)

        if items.count > Self.maxStoredItems {
            items = Array(items.prefix(Self.maxStoredItems))
        }

        persist()
    }

    func clear() {
        items = []
        userDefaults.removeObject(forKey: storageKey)
    }

    private func persist() {
        guard let data = try? encoder.encode(items) else {
            return
        }

        userDefaults.set(data, forKey: storageKey)
    }

    private static func loadItems(
        from userDefaults: UserDefaults,
        key: String,
        decoder: JSONDecoder
    ) -> [CalculationHistoryItem] {
        guard
            let data = userDefaults.data(forKey: key),
            let items = try? decoder.decode([CalculationHistoryItem].self, from: data)
        else {
            return []
        }

        return Array(items.prefix(maxStoredItems))
    }
}

import Foundation

final class HistoryStore {
    static let maxStoredItems = 25

    func list() -> [CalculationHistoryItem] {
        []
    }

    func save(_ item: CalculationHistoryItem) {
        _ = item
    }

    func clear() {
    }
}

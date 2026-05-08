import Foundation

final class SettingsStore {
    enum Unit: String, Codable, Equatable {
        case liter
        case kilometer
    }

    var unit: Unit = .liter
    var gasolineConsumption: Decimal?
    var ethanolConsumption: Decimal?
    var notificationsEnabled = false
    var priceReminderEnabled = false
}

import Foundation
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    enum Unit: String, Codable, Equatable {
        case liter
        case kilometer
    }

    @Published var unit: Unit {
        didSet { userDefaults.set(unit.rawValue, forKey: Keys.unit) }
    }

    @Published var gasolineConsumption: String {
        didSet { userDefaults.set(gasolineConsumption, forKey: Keys.gasolineConsumption) }
    }

    @Published var ethanolConsumption: String {
        didSet { userDefaults.set(ethanolConsumption, forKey: Keys.ethanolConsumption) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { userDefaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }

    @Published var priceReminderEnabled: Bool {
        didSet { userDefaults.set(priceReminderEnabled, forKey: Keys.priceReminderEnabled) }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.unit = Unit(rawValue: userDefaults.string(forKey: Keys.unit) ?? "") ?? .kilometer
        self.gasolineConsumption = userDefaults.string(forKey: Keys.gasolineConsumption) ?? ""
        self.ethanolConsumption = userDefaults.string(forKey: Keys.ethanolConsumption) ?? ""
        self.notificationsEnabled = userDefaults.bool(forKey: Keys.notificationsEnabled)
        self.priceReminderEnabled = userDefaults.bool(forKey: Keys.priceReminderEnabled)
    }
}

private enum Keys {
    static let unit = "settings_unit"
    static let gasolineConsumption = "settings_gasoline_consumption"
    static let ethanolConsumption = "settings_ethanol_consumption"
    static let notificationsEnabled = "settings_notifications_enabled"
    static let priceReminderEnabled = "settings_price_reminder_enabled"
}

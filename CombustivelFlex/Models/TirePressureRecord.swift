import Foundation
import UserNotifications

struct TirePressureRecord: Codable, Hashable, Identifiable {
    var id: Double { timestamp }

    var timestamp: Double
    var date: String
    var km: Int?
    var wasFueled: Bool
    var tireCondition: String
    var frontLeft: Int
    var frontRight: Int
    var rearLeft: Int
    var rearRight: Int

    var nextCheckDate: String {
        guard let baseDate = TirePressureFormatting.date(from: date),
              let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: baseDate) else {
            return date
        }

        return TirePressureFormatting.dateString(from: nextDate)
    }
}

enum TirePressureStore {
    private static let key = "tire_pressure_history"
    private static let maxHistory = 25

    static func getHistory() -> [TirePressureRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([TirePressureRecord].self, from: data) else {
            return []
        }

        return list
    }

    @discardableResult
    static func save(_ record: TirePressureRecord) -> TirePressureRecord {
        var storedRecord = record
        storedRecord.timestamp = Date().timeIntervalSince1970 * 1000

        var history = getHistory()
        history.insert(storedRecord, at: 0)

        if history.count > maxHistory {
            history = Array(history.prefix(maxHistory))
        }

        persist(history)
        return storedRecord
    }

    static func getLatest() -> TirePressureRecord? {
        getHistory().first
    }

    static func update(_ updated: TirePressureRecord) {
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

    private static func persist(_ history: [TirePressureRecord]) {
        guard let data = try? JSONEncoder().encode(history) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

enum TirePressureFormatting {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from text: String) -> Date? {
        dateFormatter.date(from: text)
    }

    static func kmText(_ value: Int?) -> String {
        guard let value else {
            return "Não informado"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0

        return "\(formatter.string(from: NSNumber(value: value)) ?? "0") km"
    }

    static func parseNumber(_ text: String) -> Int {
        Int(text.filter(\.isNumber)) ?? 0
    }

    static func numberField(_ value: Int) -> String {
        guard value > 0 else {
            return ""
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

struct TirePressureReminderSettings: Codable {
    var isEnabled: Bool
    var intervalDays: Int

    static let standard = TirePressureReminderSettings(isEnabled: true, intervalDays: 7)
}

enum TirePressureReminderStore {
    private static let key = "tire_pressure_reminder_settings"
    private static let notificationIdentifier = "tire_pressure_reminder"

    static func getSettings() -> TirePressureReminderSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(TirePressureReminderSettings.self, from: data) else {
            return .standard
        }

        return settings
    }

    static func save(_ settings: TirePressureReminderSettings, completion: @escaping (Bool) -> Void) {
        if !settings.isEnabled {
            persist(settings)
            removeScheduledReminder()
            completion(true)
            return
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, _ in
            if isGranted {
                persist(settings)
                scheduleReminder(settings)
                completion(true)
            } else {
                persist(TirePressureReminderSettings(isEnabled: false, intervalDays: settings.intervalDays))
                removeScheduledReminder()
                completion(false)
            }
        }
    }

    private static func scheduleReminder(_ settings: TirePressureReminderSettings) {
        removeScheduledReminder()

        let content = UNMutableNotificationContent()
        content.title = "Hora de calibrar os pneus"
        content.body = "Verifique a pressão recomendada e calibre com os pneus frios para economizar combustível."
        content.sound = .default

        let interval = TimeInterval(settings.intervalDays * 24 * 60 * 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private static func removeScheduledReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }

    private static func persist(_ settings: TirePressureReminderSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

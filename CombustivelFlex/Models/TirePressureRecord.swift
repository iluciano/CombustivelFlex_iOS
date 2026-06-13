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
    var nextFireDate: Date?

    static let standard = TirePressureReminderSettings(isEnabled: true, intervalDays: 7, nextFireDate: nil)
}

enum TirePressureReminderStore {
    private static let key = "tire_pressure_reminder_settings"
    private static let notificationIdentifier = "tire_pressure_reminder"
    private static let scheduledNotificationCount = 12
    private static let allowedIntervals = [7, 15, 30]

    static func getSettings() -> TirePressureReminderSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let settings = try? JSONDecoder().decode(TirePressureReminderSettings.self, from: data) else {
            return .standard
        }

        return sanitizedSettings(settings)
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
                let scheduledSettings = settingsForNewSchedule(settings)
                persist(scheduledSettings)
                scheduleReminder(scheduledSettings)
                completion(true)
            } else {
                persist(TirePressureReminderSettings(isEnabled: false, intervalDays: settings.intervalDays, nextFireDate: nil))
                removeScheduledReminder()
                completion(false)
            }
        }
    }

    static func refreshScheduledReminders() {
        var settings = getSettings()

        guard settings.isEnabled else {
            removeScheduledReminder()
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            guard notificationSettings.authorizationStatus == .authorized ||
                  notificationSettings.authorizationStatus == .provisional else {
                return
            }

            settings = normalizedSettings(settings)
            persist(settings)
            scheduleReminder(settings)
        }
    }

    private static func scheduleReminder(_ settings: TirePressureReminderSettings) {
        removeScheduledReminder()

        let calendar = Calendar.current
        let startDate = settings.nextFireDate ?? nextFireDate(from: Date(), intervalDays: settings.intervalDays)

        for index in 0..<scheduledNotificationCount {
            guard let fireDate = reminderDate(from: startDate, interval: settings.intervalDays, multiplier: index) else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "Hora de calibrar os pneus"
            content.body = "Verifique a pressão recomendada e calibre com os pneus frios para economizar combustível."
            content.sound = .default

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: notificationIdentifier(for: index), content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    private static func removeScheduledReminder() {
        let identifiers = [notificationIdentifier] + (0..<scheduledNotificationCount).map(notificationIdentifier(for:))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func persist(_ settings: TirePressureReminderSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }

    private static func settingsForNewSchedule(_ settings: TirePressureReminderSettings) -> TirePressureReminderSettings {
        let intervalDays = sanitizedInterval(settings.intervalDays)

        return TirePressureReminderSettings(
            isEnabled: settings.isEnabled,
            intervalDays: intervalDays,
            nextFireDate: nextFireDate(from: Date(), intervalDays: intervalDays)
        )
    }

    private static func normalizedSettings(_ settings: TirePressureReminderSettings) -> TirePressureReminderSettings {
        let settings = sanitizedSettings(settings)
        var nextDate = settings.nextFireDate ?? nextFireDate(from: Date(), intervalDays: settings.intervalDays)

        while nextDate <= Date() {
            nextDate = nextFireDate(from: nextDate, intervalDays: settings.intervalDays)
        }

        return TirePressureReminderSettings(
            isEnabled: settings.isEnabled,
            intervalDays: settings.intervalDays,
            nextFireDate: nextDate
        )
    }

    private static func nextFireDate(from date: Date, intervalDays: Int) -> Date {
        reminderDate(from: date, interval: intervalDays, multiplier: 1) ?? date.addingTimeInterval(TimeInterval(intervalDays * 24 * 60 * 60))
    }

    private static func reminderDate(from date: Date, interval: Int, multiplier: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: interval * multiplier, to: date)
    }

    private static func notificationIdentifier(for index: Int) -> String {
        "\(notificationIdentifier)_\(index)"
    }

    private static func sanitizedSettings(_ settings: TirePressureReminderSettings) -> TirePressureReminderSettings {
        TirePressureReminderSettings(
            isEnabled: settings.isEnabled,
            intervalDays: sanitizedInterval(settings.intervalDays),
            nextFireDate: settings.nextFireDate
        )
    }

    private static func sanitizedInterval(_ intervalDays: Int) -> Int {
        allowedIntervals.contains(intervalDays) ? intervalDays : TirePressureReminderSettings.standard.intervalDays
    }
}

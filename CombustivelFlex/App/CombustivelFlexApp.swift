import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct CombustivelFlexApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        AdMobStartup.shared.start()
        TirePressureReminderStore.refreshScheduledReminders()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

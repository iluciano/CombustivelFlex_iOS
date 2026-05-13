import SwiftUI
import GoogleMobileAds

@main
struct CombustivelFlexApp: App {
    init() {
        AdMobStartup.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

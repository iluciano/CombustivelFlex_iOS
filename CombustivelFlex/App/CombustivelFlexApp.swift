import SwiftUI
import GoogleMobileAds

@main
struct CombustivelFlexApp: App {
    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}

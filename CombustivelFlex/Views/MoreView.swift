import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            NavigationLink {
                TipsView()
            } label: {
                FeatureRow(title: "Dicas de economia", subtitle: "Aprenda a economizar combustível", systemImage: "lightbulb")
            }

            NavigationLink {
                SettingsView()
            } label: {
                FeatureRow(title: "Configurações", subtitle: "Personalize suas preferências", systemImage: "gearshape")
            }
        }
        .navigationTitle("Mais")
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobNativeAdView(adUnitID: AdMobConfig.Native.more)
        }
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}

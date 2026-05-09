import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: View {
    let adUnitID: String

    var body: some View {
        GeometryReader { proxy in
            let adSize = largeAnchoredAdaptiveBanner(width: proxy.size.width)

            BannerViewContainer(adUnitID: adUnitID, adSize: adSize)
                .frame(width: adSize.size.width, height: adSize.size.height)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .background(AppTheme.Colors.surface)
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.adSize = adSize

        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
            uiView.load(Request())
        }
    }
}

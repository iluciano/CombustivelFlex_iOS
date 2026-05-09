import SwiftUI
import GoogleMobileAds
import UIKit

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

private enum AdMobFooterLayout {
    static let tabBarClearance: CGFloat = 72
}

extension View {
    func adMobBannerFooter(adUnitID: String) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobFooterContainer {
                AdMobBannerView(adUnitID: adUnitID)
            }
        }
    }

    func adMobNativeFooter(adUnitID: String) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobFooterContainer {
                AdMobNativeAdView(adUnitID: adUnitID)
            }
        }
    }
}

private struct AdMobFooterContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content

            Color.clear
                .frame(height: AdMobFooterLayout.tabBarClearance)
        }
        .background(AppTheme.Colors.surface)
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = AdMobPresentationContext.rootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.adSize = adSize
        uiView.rootViewController = AdMobPresentationContext.rootViewController

        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
            uiView.load(Request())
        }
    }
}

enum AdMobPresentationContext {
    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

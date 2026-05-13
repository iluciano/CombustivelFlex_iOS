import SwiftUI
import GoogleMobileAds
import UIKit

struct AdMobBannerView: View {
    let adUnitID: String
    var reservesTabBarClearance = true
    @State private var isLoaded = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                let adSize = largeAnchoredAdaptiveBanner(width: proxy.size.width)

                BannerViewContainer(
                    adUnitID: adUnitID,
                    adSize: adSize,
                    isLoaded: $isLoaded
                )
                    .frame(width: adSize.size.width, height: adSize.size.height)
                    .frame(maxWidth: .infinity)
                    .opacity(isLoaded ? 1 : 0)
            }
            .frame(height: isLoaded ? 60 : 0)
            .background(AppTheme.Colors.surface)

            if isLoaded && reservesTabBarClearance {
                Color.clear
                    .frame(height: AdMobFooterLayout.tabBarClearance)
            }
        }
    }
}

private enum AdMobFooterLayout {
    static let tabBarClearance: CGFloat = 88
}

extension View {
    func adMobBannerFooter(adUnitID: String) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobFooterContainer {
                AdMobBannerView(adUnitID: adUnitID, reservesTabBarClearance: true)
            }
        }
    }

    func adMobNativeFooter(adUnitID: String) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobFooterContainer {
                AdMobNativeAdView(adUnitID: adUnitID, reservesTabBarClearance: true)
            }
        }
    }
}

private struct AdMobFooterContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize
    @Binding var isLoaded: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoaded: $isLoaded)
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.rootViewController = AdMobPresentationContext.rootViewController
        loadAdIfPossible(in: bannerView, coordinator: context.coordinator)
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.adSize = adSize
        uiView.rootViewController = AdMobPresentationContext.rootViewController

        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
            context.coordinator.reset()
        }

        loadAdIfPossible(in: uiView, coordinator: context.coordinator)
    }

    private func loadAdIfPossible(in bannerView: BannerView, coordinator: Coordinator) {
        guard bannerView.rootViewController != nil else {
            guard !coordinator.didScheduleRootRetry else {
                return
            }

            coordinator.didScheduleRootRetry = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                coordinator.didScheduleRootRetry = false
                bannerView.rootViewController = AdMobPresentationContext.rootViewController
                loadAdIfPossible(in: bannerView, coordinator: coordinator)
            }
            return
        }

        guard !coordinator.didRequestAd else {
            return
        }

        coordinator.didRequestAd = true
        AdMobStartup.shared.whenReady {
            bannerView.load(Request())
        }
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        var didRequestAd = false
        var didScheduleRootRetry = false
        @Binding private var isLoaded: Bool

        init(isLoaded: Binding<Bool>) {
            _isLoaded = isLoaded
        }

        func reset() {
            didRequestAd = false
            didScheduleRootRetry = false
            isLoaded = false
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            isLoaded = true
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            isLoaded = false
        }
    }
}

final class AdMobStartup {
    static let shared = AdMobStartup()

    private var isStarted = false
    private var isStarting = false
    private var completions: [() -> Void] = []

    private init() {}

    func start() {
        DispatchQueue.main.async {
            guard !self.isStarted, !self.isStarting else {
                return
            }

            self.isStarting = true
            MobileAds.shared.start { _ in
                DispatchQueue.main.async {
                    self.isStarted = true
                    self.isStarting = false

                    let completions = self.completions
                    self.completions.removeAll()
                    completions.forEach { $0() }
                }
            }
        }
    }

    func whenReady(_ completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if self.isStarted {
                completion()
                return
            }

            self.completions.append(completion)
            self.start()
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

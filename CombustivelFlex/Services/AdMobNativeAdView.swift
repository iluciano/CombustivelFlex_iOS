import SwiftUI
import GoogleMobileAds

@MainActor
final class NativeAdViewModel: NSObject, ObservableObject {
    @Published var nativeAd: NativeAd?

    private let adUnitID: String
    private var adLoader: AdLoader?

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
    }

    func load() {
        let loader = AdLoader(
            adUnitID: adUnitID,
            rootViewController: AdMobPresentationContext.rootViewController,
            adTypes: [.native],
            options: nil
        )
        loader.delegate = self
        loader.load(Request())
        adLoader = loader
    }
}

extension NativeAdViewModel: NativeAdLoaderDelegate {
    nonisolated func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        Task { @MainActor in
            self.nativeAd = nativeAd
        }
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        #if DEBUG
        print("Native ad failed to load: \(error.localizedDescription)")
        #endif
    }
}

struct AdMobNativeAdView: View {
    @StateObject private var viewModel: NativeAdViewModel

    init(adUnitID: String) {
        _viewModel = StateObject(wrappedValue: NativeAdViewModel(adUnitID: adUnitID))
    }

    var body: some View {
        NativeAdContainer(viewModel: viewModel)
            .frame(height: 144)
            .background(AppTheme.Colors.surface)
            .task {
                viewModel.load()
            }
    }
}

private struct NativeAdContainer: UIViewRepresentable {
    @ObservedObject var viewModel: NativeAdViewModel

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()
        adView.backgroundColor = .white

        let badgeLabel = UILabel()
        badgeLabel.text = "Ad"
        badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = UIColor.systemYellow
        badgeLabel.layer.cornerRadius = 3
        badgeLabel.layer.masksToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        let mediaView = MediaView()
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        mediaView.layer.cornerRadius = 8
        mediaView.translatesAutoresizingMaskIntoConstraints = false

        let headlineLabel = UILabel()
        headlineLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        headlineLabel.textColor = UIColor(Color(hex: 0x101828))
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 12)
        bodyLabel.textColor = UIColor(Color(hex: 0x475467))
        bodyLabel.numberOfLines = 2
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        let callToActionButton = UIButton(type: .system)
        callToActionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        callToActionButton.tintColor = .white
        callToActionButton.backgroundColor = UIColor(Color(hex: 0x1473F8))
        callToActionButton.layer.cornerRadius = 20
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false

        adView.addSubview(badgeLabel)
        adView.addSubview(mediaView)
        adView.addSubview(headlineLabel)
        adView.addSubview(bodyLabel)
        adView.addSubview(callToActionButton)

        adView.mediaView = mediaView
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.callToActionView = callToActionButton

        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            badgeLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            badgeLabel.widthAnchor.constraint(equalToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16),

            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            mediaView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            mediaView.widthAnchor.constraint(equalToConstant: 120),
            mediaView.heightAnchor.constraint(equalToConstant: 120),

            callToActionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            callToActionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            callToActionButton.widthAnchor.constraint(equalToConstant: 92),
            callToActionButton.heightAnchor.constraint(equalToConstant: 40),

            headlineLabel.leadingAnchor.constraint(equalTo: mediaView.trailingAnchor, constant: 12),
            headlineLabel.trailingAnchor.constraint(equalTo: callToActionButton.leadingAnchor, constant: -10),
            headlineLabel.topAnchor.constraint(equalTo: mediaView.topAnchor, constant: 22),

            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 5),
        ])

        return adView
    }

    func updateUIView(_ adView: NativeAdView, context: Context) {
        guard let nativeAd = viewModel.nativeAd else {
            return
        }

        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        adView.bodyView?.isHidden = nativeAd.body == nil
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        adView.callToActionView?.isHidden = nativeAd.callToAction == nil
        adView.callToActionView?.isUserInteractionEnabled = false
        adView.nativeAd = nativeAd
    }
}

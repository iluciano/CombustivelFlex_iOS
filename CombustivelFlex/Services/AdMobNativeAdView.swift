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
            rootViewController: nil,
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
        print("Native ad failed to load: \(error.localizedDescription)")
    }
}

struct AdMobNativeAdView: View {
    @StateObject private var viewModel: NativeAdViewModel

    init(adUnitID: String) {
        _viewModel = StateObject(wrappedValue: NativeAdViewModel(adUnitID: adUnitID))
    }

    var body: some View {
        NativeAdContainer(viewModel: viewModel)
            .frame(height: 96)
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

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 8
        iconView.layer.masksToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let headlineLabel = UILabel()
        headlineLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        headlineLabel.textColor = UIColor(Color(hex: 0x101828))
        headlineLabel.numberOfLines = 1
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 14)
        bodyLabel.textColor = UIColor(Color(hex: 0x475467))
        bodyLabel.numberOfLines = 1
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        let callToActionButton = UIButton(type: .system)
        callToActionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        callToActionButton.tintColor = .white
        callToActionButton.backgroundColor = UIColor(Color(hex: 0x1473F8))
        callToActionButton.layer.cornerRadius = 24
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false

        adView.addSubview(badgeLabel)
        adView.addSubview(iconView)
        adView.addSubview(headlineLabel)
        adView.addSubview(bodyLabel)
        adView.addSubview(callToActionButton)

        adView.iconView = iconView
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.callToActionView = callToActionButton

        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            badgeLabel.topAnchor.constraint(equalTo: adView.topAnchor, constant: 8),
            badgeLabel.widthAnchor.constraint(equalToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16),

            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 54),
            iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            callToActionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            callToActionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            callToActionButton.widthAnchor.constraint(equalToConstant: 112),
            callToActionButton.heightAnchor.constraint(equalToConstant: 48),

            headlineLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            headlineLabel.trailingAnchor.constraint(equalTo: callToActionButton.leadingAnchor, constant: -12),
            headlineLabel.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),

            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
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
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        adView.iconView?.isHidden = nativeAd.icon == nil
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        adView.callToActionView?.isHidden = nativeAd.callToAction == nil
        adView.callToActionView?.isUserInteractionEnabled = false
        adView.nativeAd = nativeAd
    }
}

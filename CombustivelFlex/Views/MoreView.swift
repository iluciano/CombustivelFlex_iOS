import SwiftUI

struct MoreView: View {
    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    Text("Mais")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(MoreViewColors.textPrimary)

                    VStack(spacing: AppTheme.Spacing.large) {
                        NavigationLink {
                            TipsView()
                        } label: {
                            MoreOptionCard(
                                title: "Dicas de economia",
                                subtitle: "Aprenda a economizar combustível no dia a dia",
                                systemImage: "lightbulb.fill",
                                tint: AppTheme.Colors.orange
                            )
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            MoreOptionCard(
                                title: "Configurações",
                                subtitle: "Personalize suas preferências e o aplicativo",
                                systemImage: "gearshape.fill",
                                tint: AppTheme.Colors.textMuted
                            )
                        }
                    }

                    AdMobNativeAdView(adUnitID: AdMobConfig.Native.more, reservesTabBarClearance: false)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(MoreViewColors.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MoreOptionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MoreViewColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(MoreViewColors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.title2.weight(.semibold))
                .foregroundStyle(MoreViewColors.chevron)
        }
        .padding(AppTheme.Spacing.large)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .background(MoreViewColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(MoreViewColors.divider, lineWidth: 1)
        }
        .shadow(color: MoreViewColors.shadow, radius: 5, x: 0, y: 3)
    }
}

private enum MoreViewColors {
    static let background = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? .black
                : UIColor(hex: 0xF6F8FC)
        }
    )

    static let surface = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(hex: 0x1F2937)
                : .white
        }
    )

    static let textPrimary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? .white
                : UIColor(hex: 0x101828)
        }
    )

    static let textSecondary = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.72)
                : UIColor(hex: 0x475467)
        }
    )

    static let chevron = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.45)
                : UIColor(hex: 0x98A2B3)
        }
    )

    static let divider = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 1, alpha: 0.08)
                : UIColor(hex: 0xE4E7EC)
        }
    )

    static let shadow = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.clear
                : UIColor.black.withAlphaComponent(0.10)
        }
    )
}

#Preview {
    NavigationStack {
        MoreView()
    }
}

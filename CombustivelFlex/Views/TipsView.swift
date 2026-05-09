import SwiftUI

struct TipsView: View {
    private let tips = [
        EconomyTip(
            systemImage: "circle.circle",
            iconColor: AppTheme.Colors.textPrimary,
            title: "Mantenha os pneus calibrados",
            subtitle: "Pneus calibrados podem economizar até 10% de combustível."
        ),
        EconomyTip(
            systemImage: "road.lanes",
            iconColor: AppTheme.Colors.orange,
            title: "Evite acelerações bruscas",
            subtitle: "Acelerações suaves podem reduzir o consumo em até 20%."
        ),
        EconomyTip(
            systemImage: "wrench.adjustable.fill",
            iconColor: AppTheme.Colors.textPrimary,
            title: "Faça revisões periódicas",
            subtitle: "Um carro revisado pode economizar até 15% de combustível."
        ),
        EconomyTip(
            systemImage: "air.conditioner.horizontal.fill",
            iconColor: AppTheme.Colors.textPrimary,
            title: "Use o ar-condicionado com moderação",
            subtitle: "O ar-condicionado pode aumentar o consumo em até 20%."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                Text("Dicas de economia")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.top, AppTheme.Spacing.large)

                VStack(spacing: AppTheme.Spacing.large) {
                    ForEach(tips) { tip in
                        EconomyTipCard(tip: tip)
                    }
                }
            }
            .padding(AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .adMobBannerFooter(adUnitID: AdMobConfig.Banner.tips)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct EconomyTip: Identifiable {
    let id = UUID()
    let systemImage: String
    let iconColor: Color
    let title: String
    let subtitle: String
}

private struct EconomyTipCard: View {
    let tip: EconomyTip

    var body: some View {
        AppCard {
            HStack(alignment: .center, spacing: AppTheme.Spacing.large) {
                Image(systemName: tip.systemImage)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(tip.iconColor)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(tip.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(tip.subtitle)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, AppTheme.Spacing.medium)
        }
        .shadow(color: .black.opacity(0.10), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    TipsView()
}

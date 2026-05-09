import SwiftUI

struct StationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                Image("stations_hero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppTheme.Spacing.medium)

                Text("EM BREVE")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.Colors.blue)
                    .padding(.horizontal, AppTheme.Spacing.medium)
                    .padding(.vertical, AppTheme.Spacing.small)
                    .background(Color(hex: 0xE7F1FF))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))

                VStack(spacing: AppTheme.Spacing.medium) {
                    Text("Novidade chegando!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Em breve você poderá encontrar os melhores postos perto de você e economizar ainda mais no abastecimento.")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, AppTheme.Spacing.medium)
                }

                AppCard {
                    VStack(spacing: AppTheme.Spacing.large) {
                        StationFeatureRow(
                            systemImage: "mappin.circle.fill",
                            tint: AppTheme.Colors.blue,
                            title: "Postos perto de você",
                            subtitle: "Localize os postos mais próximos com facilidade."
                        )

                        StationFeatureRow(
                            systemImage: "tag.fill",
                            tint: AppTheme.Colors.green,
                            title: "Melhor preço",
                            subtitle: "Compare preços e escolha sempre a melhor opção."
                        )

                        StationFeatureRow(
                            systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                            tint: AppTheme.Colors.orange,
                            title: "Rotas rápidas",
                            subtitle: "Veja o caminho mais rápido até o posto escolhido."
                        )
                    }
                }
                .shadow(color: .black.opacity(0.14), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.bottom, AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Postos próximos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StationFeatureRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 54)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        StationsView()
    }
}

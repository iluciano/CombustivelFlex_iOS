import SwiftUI

struct ResultSummaryView: View {
    let result: FuelCalculationResult

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("O melhor combustível para o seu carro é:")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                Text(result.recommendedFuel.displayName)
                    .font(.title.bold())
                    .foregroundStyle(result.recommendedFuel == .ethanol ? AppTheme.Colors.green : AppTheme.Colors.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

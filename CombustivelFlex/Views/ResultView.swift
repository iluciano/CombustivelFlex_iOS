import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss

    let result: FuelCalculationResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                ResultSummaryView(result: result)

                PrimaryButton(title: "Recalcular") {
                    dismiss()
                }
            }
            .padding(AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Resultado")
    }
}

#Preview {
    NavigationStack {
        ResultView(result: FuelCalculationResult(recommendedFuel: .ethanol))
    }
}

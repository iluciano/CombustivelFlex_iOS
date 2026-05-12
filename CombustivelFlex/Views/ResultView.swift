import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss

    let result: FuelCalculationResult
    let onRecalculate: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.medium) {
                    fuelIcon

                    Text("O melhor combustível\npara o seu carro é:")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(result.recommendedFuel.displayName)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(recommendedColor)

                    CarIllustration()
                        .frame(width: 190, height: 72)

                    VStack(spacing: AppTheme.Spacing.small) {
                        Text("Economia estimada:")
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Text("\(currency(result.estimatedSavings)) \(savingsUnit)")
                            .font(.title2.bold())
                            .foregroundStyle(recommendedColor)
                    }
                    .padding(.top, AppTheme.Spacing.small)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, AppTheme.Spacing.large)

                comparisonSection

                PrimaryButton(title: "Recalcular") {
                    onRecalculate()
                    dismiss()
                }
            }
            .padding(AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .adMobBannerFooter(adUnitID: AdMobConfig.Banner.result)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var fuelIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.greenLight)
                .overlay {
                    Circle()
                        .stroke(AppTheme.Colors.green.opacity(0.25), lineWidth: 3)
                }

            BrandIcon(size: 58)
        }
        .frame(width: 112, height: 112)
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text(comparisonTitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.medium) {
                ResultComparisonCard(
                    title: "GASOLINA",
                    value: gasolineComparisonValue,
                    isHighlighted: result.recommendedFuel == .gasoline
                )

                ResultComparisonCard(
                    title: "ETANOL",
                    value: ethanolComparisonValue,
                    isHighlighted: result.recommendedFuel == .ethanol
                )
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color(hex: 0xF3F5FA))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }

    private var comparisonTitle: String {
        result.basis == .consumption ? "Comparativo de custo por km" : "Comparativo pela regra dos 70%"
    }

    private var gasolineComparisonValue: String {
        if let gasolineCostPerKilometer = result.gasolineCostPerKilometer {
            return "\(currency(gasolineCostPerKilometer))/km"
        }

        return "70%"
    }

    private var ethanolComparisonValue: String {
        if let ethanolCostPerKilometer = result.ethanolCostPerKilometer {
            return "\(currency(ethanolCostPerKilometer))/km"
        }

        if let priceRatio = result.priceRatio {
            return percent(priceRatio)
        }

        return "-"
    }

    private var recommendedColor: Color {
        result.recommendedFuel == .ethanol ? AppTheme.Colors.green : AppTheme.Colors.orange
    }

    private var savingsUnit: String {
        result.basis == .consumption ? "por km" : "por litro"
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "R$ 0,00"
    }

    private func percent(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "-"
    }
}

private struct ResultComparisonCard: View {
    let title: String
    let value: String
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(isHighlighted ? AppTheme.Colors.green : AppTheme.Colors.textPrimary)

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(isHighlighted ? AppTheme.Colors.green : AppTheme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .background(isHighlighted ? Color(hex: 0xD1FADF) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }
}

private struct CarIllustration: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(Color.black.opacity(0.08))
                .frame(width: 154, height: 10)
                .offset(y: 4)

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: 0xFFC107))
                    .frame(width: 150, height: 42)
                    .offset(y: 8)

                Path { path in
                    path.move(to: CGPoint(x: 50, y: 28))
                    path.addLine(to: CGPoint(x: 76, y: 4))
                    path.addLine(to: CGPoint(x: 119, y: 4))
                    path.addLine(to: CGPoint(x: 145, y: 28))
                    path.closeSubpath()
                }
                .fill(Color(hex: 0xFFD54F))

                Path { path in
                    path.move(to: CGPoint(x: 78, y: 9))
                    path.addLine(to: CGPoint(x: 63, y: 27))
                    path.addLine(to: CGPoint(x: 100, y: 27))
                    path.addLine(to: CGPoint(x: 100, y: 9))
                    path.closeSubpath()
                }
                .fill(Color(hex: 0xB7D7E8))

                Path { path in
                    path.move(to: CGPoint(x: 106, y: 9))
                    path.addLine(to: CGPoint(x: 106, y: 27))
                    path.addLine(to: CGPoint(x: 136, y: 27))
                    path.addLine(to: CGPoint(x: 118, y: 9))
                    path.closeSubpath()
                }
                .fill(Color(hex: 0xB7D7E8))

                Wheel()
                    .offset(x: -48, y: 31)

                Wheel()
                    .offset(x: 54, y: 31)
            }
            .frame(width: 190, height: 72)
        }
    }
}

private struct Wheel: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x263238))

            Circle()
                .fill(Color(hex: 0xFF9800))
                .frame(width: 18, height: 18)

            Circle()
                .fill(Color.white)
                .frame(width: 7, height: 7)
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    NavigationStack {
        ResultView(
            result: FuelCalculationResult(
                recommendedFuel: .ethanol,
                basis: .consumption,
                priceRatio: nil,
                gasolineCostPerKilometer: Decimal(sign: .plus, exponent: -2, significand: 75),
                ethanolCostPerKilometer: Decimal(sign: .plus, exponent: -2, significand: 64),
                estimatedSavings: Decimal(sign: .plus, exponent: -2, significand: 11)
            ),
            onRecalculate: {}
        )
    }
}

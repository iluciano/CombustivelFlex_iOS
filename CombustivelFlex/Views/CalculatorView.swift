import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var shouldShowResult = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                AppCard {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        FuelTextField(
                            title: "Preco da gasolina",
                            placeholder: "R$ 0,00",
                            text: $viewModel.gasolinePrice,
                            tint: AppTheme.Colors.orange
                        )

                        Divider()

                        FuelTextField(
                            title: "Preco do etanol",
                            placeholder: "R$ 0,00",
                            text: $viewModel.ethanolPrice,
                            tint: AppTheme.Colors.green
                        )
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        Text("Meu carro faz")
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        HStack(spacing: AppTheme.Spacing.medium) {
                            FuelTextField(
                                title: "Gasolina",
                                placeholder: "0,0 km/L",
                                text: $viewModel.gasolineConsumption,
                                tint: AppTheme.Colors.orange
                            )

                            FuelTextField(
                                title: "Etanol",
                                placeholder: "0,0 km/L",
                                text: $viewModel.ethanolConsumption,
                                tint: AppTheme.Colors.green
                            )
                        }
                    }
                }

                PrimaryButton(title: "Calcular") {
                    shouldShowResult = viewModel.calculate()
                }
            }
            .padding(AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Calcular combustível")
        .navigationDestination(isPresented: $shouldShowResult) {
            if let result = viewModel.result {
                ResultView(result: result)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CalculatorView()
    }
}

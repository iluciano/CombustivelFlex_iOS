import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var settingsStore: SettingsStore
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var shouldShowResult = false
    @State private var shouldConfirmDefaultConsumption = false

    var body: some View {
        ScrollView {
            RoadHeaderView()
                .frame(height: 255)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: AppTheme.Spacing.large) {
                brandHeader
                formContent
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, 34)
            .padding(.bottom, AppTheme.Spacing.large)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 5)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .offset(y: -70)
            .padding(.bottom, -46)
        }
        .background(AppTheme.Colors.background)
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.applyDefaultConsumption(
                gasoline: settingsStore.gasolineConsumption,
                ethanol: settingsStore.ethanolConsumption
            )
        }
        .confirmationDialog(
            "Salvar consumo padrão?",
            isPresented: $shouldConfirmDefaultConsumption,
            titleVisibility: .visible
        ) {
            Button(defaultConsumptionActionTitle) {
                saveDefaultConsumption()
                shouldShowResult = true
            }

            Button("Agora não") {
                shouldShowResult = true
            }
        } message: {
            Text("Deseja usar os valores informados como padrão para os próximos cálculos?")
        }
        .navigationDestination(isPresented: $shouldShowResult) {
            if let result = viewModel.result {
                ResultView(
                    result: result,
                    onRecalculate: {
                        viewModel.clear()
                    }
                )
            }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack(spacing: AppTheme.Spacing.small) {
                BrandIcon()

                HStack(spacing: 4) {
                    Text("COMBUSTÍVEL")
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("FLEX")
                        .foregroundStyle(AppTheme.Colors.blue)
                }
                .font(.title2.bold())
            }

            Text("Qual o melhor combustível para o seu carro?")
                .font(.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            AppCard {
                VStack(spacing: AppTheme.Spacing.medium) {
                    FuelTextField(
                        title: "Preço da gasolina",
                        placeholder: "R$ 0,00",
                        text: $viewModel.gasolinePrice,
                        tint: AppTheme.Colors.orange
                    )

                    Divider()

                    FuelTextField(
                        title: "Preço do etanol",
                        placeholder: "R$ 0,00",
                        text: $viewModel.ethanolPrice,
                        tint: AppTheme.Colors.green
                    )
                }
            }

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
                    .frame(maxWidth: .infinity)

                    FuelTextField(
                        title: "Etanol",
                        placeholder: "0,0 km/L",
                        text: $viewModel.ethanolConsumption,
                        tint: AppTheme.Colors.green
                    )
                    .frame(maxWidth: .infinity)
                }
            }

            PrimaryButton(title: "Calcular") {
                calculate()
            }

            SecondaryButton(title: "Limpar") {
                viewModel.clear()
                shouldShowResult = false
            }

            AdMobBannerView(adUnitID: AdMobConfig.Banner.calculator, reservesTabBarClearance: false)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func calculate() {
        if viewModel.calculate() {
            if let item = viewModel.makeHistoryItem() {
                historyStore.save(item)
            }

            if shouldAskToSaveDefaultConsumption {
                shouldConfirmDefaultConsumption = true
            } else {
                shouldShowResult = true
            }
        } else {
            shouldShowResult = false
        }
    }

    private var shouldAskToSaveDefaultConsumption: Bool {
        guard let candidate = viewModel.defaultConsumptionCandidate() else {
            return false
        }

        return candidate.gasoline != settingsStore.gasolineConsumption ||
            candidate.ethanol != settingsStore.ethanolConsumption
    }

    private var defaultConsumptionActionTitle: String {
        settingsStore.gasolineConsumption.isEmpty && settingsStore.ethanolConsumption.isEmpty
            ? "Salvar padrão"
            : "Substituir padrão"
    }

    private func saveDefaultConsumption() {
        guard let candidate = viewModel.defaultConsumptionCandidate() else {
            return
        }

        settingsStore.gasolineConsumption = candidate.gasoline
        settingsStore.ethanolConsumption = candidate.ethanol
    }
}

#Preview {
    NavigationStack {
        CalculatorView()
    }
    .environmentObject(HistoryStore())
    .environmentObject(SettingsStore())
}

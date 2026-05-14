import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @State private var shouldConfirmClear = false

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    HStack(alignment: .center) {
                        Text("Histórico")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Spacer()

                        if !historyStore.items.isEmpty {
                            Button {
                                shouldConfirmClear = true
                            } label: {
                                Label("Limpar", systemImage: "trash")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, AppTheme.Spacing.medium)
                                    .frame(height: 38)
                                    .background(Color.red.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Limpar histórico")
                        }
                    }

                    if historyStore.items.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            ForEach(historyStore.items) { item in
                                HistoryItemView(item: item)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "Limpar histórico?",
            isPresented: $shouldConfirmClear,
            titleVisibility: .visible
        ) {
            Button("Limpar histórico", role: .destructive) {
                historyStore.clear()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.blue)

            Text("Histórico de cálculos")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Os cálculos salvos neste aparelho vão aparecer aqui.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.large)
    }
}

private struct HistoryItemView: View {
    let item: CalculationHistoryItem

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                    Image(systemName: item.result == .ethanol ? "fuelpump.fill" : "fuelpump")
                        .font(.title2)
                        .foregroundStyle(item.result == .ethanol ? AppTheme.Colors.green : AppTheme.Colors.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.result.displayName)
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Text(item.basis == .consumption ? "Custo por km" : "Regra dos 70%")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Text(item.createdAt, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textMuted)
                }

                VStack(spacing: AppTheme.Spacing.small) {
                    HistoryValueRow(title: "Gasolina", value: currency(item.gasolinePrice))
                    HistoryValueRow(title: "Etanol", value: currency(item.ethanolPrice))

                    if let gasolineConsumption = item.gasolineConsumption,
                       let ethanolConsumption = item.ethanolConsumption {
                        HistoryValueRow(
                            title: "Consumo",
                            value: "\(decimal(gasolineConsumption)) / \(decimal(ethanolConsumption)) km/L"
                        )
                    }

                    HistoryValueRow(title: "Economia estimada", value: currency(item.estimatedSavings))
                }
            }
        }
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "R$ 0,00"
    }

    private func decimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1

        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0,0"
    }
}

private struct HistoryValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Spacer(minLength: AppTheme.Spacing.medium)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .environmentObject(HistoryStore())
}

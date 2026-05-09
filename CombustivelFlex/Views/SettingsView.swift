import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var editingFuel: EditableFuel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                Text("Configurações")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .padding(.top, AppTheme.Spacing.large)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text("Unidade de medida")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    HStack(spacing: AppTheme.Spacing.medium) {
                        UnitButton(title: "R$/L (litro)", unit: .liter)
                        UnitButton(title: "R$/km", unit: .kilometer)
                    }
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text("Consumo padrão do meu carro")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    HStack(spacing: AppTheme.Spacing.medium) {
                        ConsumptionCard(
                            title: "Gasolina",
                            value: settingsStore.gasolineConsumption,
                            fallback: "10,0 km/L"
                        ) {
                            editingFuel = .gasoline
                        }

                        ConsumptionCard(
                            title: "Etanol",
                            value: settingsStore.ethanolConsumption,
                            fallback: "7,0 km/L"
                        ) {
                            editingFuel = .ethanol
                        }
                    }
                }

                VStack(spacing: 0) {
                    SettingsToggleRow(
                        title: "Notificações",
                        isOn: notificationsBinding
                    )

                    SettingsDivider()

                    SettingsToggleRow(
                        title: "Lembrar de revisar preços",
                        isOn: $settingsStore.priceReminderEnabled
                    )

                    SettingsDivider()

                    SettingsNavigationRow(title: "Avaliar o app")

                    SettingsDivider()

                    SettingsNavigationRow(title: "Compartilhar com amigos")

                    SettingsDivider()

                    SettingsNavigationRow(title: "Sobre o Combustível Flex", subtitle: "Versão 1.0")
                }
            }
            .padding(AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AdMobBannerView(adUnitID: AdMobConfig.Banner.settings)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $editingFuel) { fuel in
            ConsumptionEditorView(fuel: fuel)
                .environmentObject(settingsStore)
                .presentationDetents([.height(260)])
        }
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.notificationsEnabled },
            set: { isEnabled in
                settingsStore.notificationsEnabled = isEnabled

                if isEnabled {
                    requestNotificationPermission()
                }
            }
        )
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isGranted, _ in
            Task { @MainActor in
                settingsStore.notificationsEnabled = isGranted
            }
        }
    }
}

private struct UnitButton: View {
    @EnvironmentObject private var settingsStore: SettingsStore

    let title: String
    let unit: SettingsStore.Unit

    var body: some View {
        Button {
            settingsStore.unit = unit
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(isSelected ? .white : AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(isSelected ? AppTheme.Colors.blue : AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                        .stroke(isSelected ? AppTheme.Colors.blue : AppTheme.Colors.divider, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var isSelected: Bool {
        settingsStore.unit == unit
    }
}

private struct ConsumptionCard: View {
    let title: String
    let value: String
    let fallback: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text(displayValue)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textMuted)
            }
            .padding(AppTheme.Spacing.medium)
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var displayValue: String {
        value.isEmpty ? fallback : "\(value.replacingOccurrences(of: ".", with: ",")) km/L"
    }
}

private struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.headline)
            .foregroundStyle(AppTheme.Colors.textPrimary)
            .tint(Color(hex: 0x218A35))
            .padding(.vertical, AppTheme.Spacing.large)
    }
}

private struct SettingsNavigationRow: View {
    let title: String
    var subtitle: String?

    var body: some View {
        Button {
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.Colors.textMuted)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textMuted)
            }
            .padding(.vertical, AppTheme.Spacing.large)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.Colors.divider)
            .frame(height: 1)
    }
}

private enum EditableFuel: String, Identifiable {
    case gasoline
    case ethanol

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gasoline: return "Gasolina"
        case .ethanol: return "Etanol"
        }
    }
}

private struct ConsumptionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settingsStore: SettingsStore

    let fuel: EditableFuel
    @State private var value = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.large) {
                FuelTextField(
                    title: fuel.title,
                    placeholder: "0,0 km/L",
                    text: $value,
                    tint: fuel == .gasoline ? AppTheme.Colors.orange : AppTheme.Colors.green
                )

                PrimaryButton(title: "Salvar") {
                    save()
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.large)
            .background(AppTheme.Colors.background)
            .navigationTitle("Consumo padrão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                value = fuel == .gasoline ? settingsStore.gasolineConsumption : settingsStore.ethanolConsumption
            }
        }
    }

    private func save() {
        switch fuel {
        case .gasoline:
            settingsStore.gasolineConsumption = completed(value)
        case .ethanol:
            settingsStore.ethanolConsumption = completed(value)
        }

        dismiss()
    }

    private func completed(_ value: String) -> String {
        let digits = value.filter(\.isNumber).prefix(4)

        guard !digits.isEmpty else {
            return ""
        }

        switch digits.count {
        case 1:
            return "\(digits).00"
        case 2, 3:
            let integerDigit = digits.prefix(1)
            let decimalDigits = digits.dropFirst(1)
            let completedDecimalDigits = String(decimalDigits).padding(toLength: 2, withPad: "0", startingAt: 0)

            return "\(integerDigit).\(completedDecimalDigits)"
        default:
            let integerDigits = digits.prefix(2)
            let decimalDigits = digits.dropFirst(2)

            return "\(integerDigits).\(decimalDigits)"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsStore())
}

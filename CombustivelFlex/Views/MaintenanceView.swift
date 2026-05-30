import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Manutenção")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Acompanhe as manutenções do carro")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .padding(.horizontal, AppTheme.Spacing.medium)

                PageCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                        NavigationLink {
                            OilChangeOverviewView()
                        } label: {
                            MaintenanceOptionRow(
                                title: "Troca de óleo",
                                subtitle: "Registre e acompanhe",
                                systemImage: "oilcan.fill",
                                tint: AppTheme.Colors.orange
                            )
                        }
                        .buttonStyle(.plain)

                        AdMobNativeAdView(
                            adUnitID: AdMobConfig.Native.maintenance,
                            reservesTabBarClearance: false,
                            showsTopDividerWhenLoaded: true
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MaintenanceOptionRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        return HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(AppTheme.Colors.divider, lineWidth: 1)
        }
    }
}

struct OilChangeOverviewView: View {
    @State private var latestRecord: OilChangeRecord?

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    statusCard

                    if let latestRecord {
                        latestSummary(latestRecord)
                    } else {
                        emptySummary
                    }

                    NavigationLink {
                        OilChangeRegisterView()
                    } label: {
                        MaintenanceButtonLabel(title: "+ Registrar nova troca", style: .primary)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OilChangeHistoryView()
                    } label: {
                        MaintenanceButtonLabel(title: "Ver histórico", style: .secondary)
                    }
                    .buttonStyle(.plain)

                    AdMobNativeAdView(
                        adUnitID: AdMobConfig.Native.oilChange,
                        reservesTabBarClearance: false,
                        showsTopDividerWhenLoaded: true
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Troca de óleo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            latestRecord = OilChangeStore.getLatest()
        }
    }

    private var statusCard: some View {
        let currentStatus = latestRecord.map(status(for:))
        let tint = currentStatus?.tint ?? AppTheme.Colors.textSecondary

        return HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "oilcan.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(currentStatus?.title ?? "Nenhuma troca registrada")
                    .font(.headline)
                    .foregroundStyle(tint)

                Text(currentStatus?.message ?? "Registre a primeira troca para começar a acompanhar.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.medium)
        .background(currentStatus?.background ?? Color(hex: 0xF2F4F7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }

    private var emptySummary: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Próxima troca em")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Registre uma troca para acompanhar prazos, quilometragem e itens substituídos.")
                .font(.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private func latestSummary(_ record: OilChangeRecord) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Próxima troca em")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(daysRemainingText(for: record))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(status(for: record).tint)

                ProgressView(value: progress(for: record))
                    .tint(status(for: record).tint)
            }

            Text("Última troca")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            MaintenanceValueRow(title: "Data", value: record.date)
            MaintenanceValueRow(title: "Km atual", value: formattedKm(record.km))
            MaintenanceValueRow(title: "Próxima troca", value: "\(formattedKm(record.nextKm)) ou \(record.nextDate)")
        }
    }

    private func status(for record: OilChangeRecord) -> OilStatus {
        let days = OilChangeFormatting.daysBetweenToday(and: record.nextDate)

        if days > 30 {
            return .ok
        }

        if days >= 0 {
            return .due
        }

        return .overdue
    }

    private func daysRemainingText(for record: OilChangeRecord) -> String {
        let days = OilChangeFormatting.daysBetweenToday(and: record.nextDate)

        if days >= 0 {
            return "\(days) dias"
        }

        return "\(abs(days)) dias de atraso"
    }

    private func progress(for record: OilChangeRecord) -> Double {
        guard let start = OilChangeFormatting.date(from: record.date),
              let end = OilChangeFormatting.date(from: record.nextDate) else {
            return 0
        }

        let total = end.timeIntervalSince(start)
        guard total > 0 else {
            return 1
        }

        return min(max(Date().timeIntervalSince(start) / total, 0), 1)
    }

    private func formattedKm(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0

        return "\(formatter.string(from: NSNumber(value: value)) ?? "0") km"
    }
}

private enum OilStatus {
    case ok
    case due
    case overdue

    var title: String {
        switch self {
        case .ok: return "Tudo em dia!"
        case .due: return "Troca se aproximando"
        case .overdue: return "Troca vencida"
        }
    }

    var message: String {
        switch self {
        case .ok: return "Seu óleo está dentro do prazo recomendado."
        case .due: return "Planeje a próxima troca para evitar atraso."
        case .overdue: return "Faça a troca assim que possível para proteger o motor."
        }
    }

    var tint: Color {
        switch self {
        case .ok: return AppTheme.Colors.green
        case .due: return AppTheme.Colors.orange
        case .overdue: return Color(hex: 0xE53935)
        }
    }

    var background: Color {
        switch self {
        case .ok: return AppTheme.Colors.greenLight
        case .due: return Color(hex: 0xFFF7ED)
        case .overdue: return Color(hex: 0xFFEBEE)
        }
    }
}

private struct MaintenanceValueRow: View {
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

private struct MaintenanceButtonLabel: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(style == .primary ? .white : AppTheme.Colors.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(style == .primary ? AppTheme.Colors.green : AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                        .stroke(AppTheme.Colors.divider, lineWidth: 1)
                }
            }
    }
}

struct OilChangeDraft: Hashable {
    var date: Date
    var km: Int
    var nextKm: Int
    var nextDate: Date
    var oilType: String
    var notes: String
}

private enum OilChangeFormatting {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    static func daysBetweenToday(and dateString: String) -> Int {
        guard let date = date(from: dateString) else {
            return 0
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    static func kmText(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: value)) ?? "0") km"
    }

    static func kmField(_ value: Int) -> String {
        kmText(value).replacingOccurrences(of: " km", with: "")
    }

    static func parseKm(_ text: String) -> Int {
        let digits = String(text.filter(\.isNumber).prefix(7))
        return min(Int(digits) ?? 0, 9_999_999)
    }

    static func sanitized(_ input: String, maxLength: Int) -> String {
        let cleaned = input.unicodeScalars.filter {
            !($0.value < 0x20 && $0 != "\n") && $0.value != 0x7F
        }
        let trimmed = String(String.UnicodeScalarView(cleaned)).trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(maxLength))
    }

    static func changedItems(for record: OilChangeRecord) -> [String] {
        [
            (record.changedEngineOil, "Óleo do motor"),
            (record.changedOilFilter, "Filtro de óleo"),
            (record.changedAirFilter, "Filtro de ar"),
            (record.changedFuelFilter, "Filtro de combustível"),
            (record.changedCabinFilter, "Filtro de cabine"),
            (record.changedBrakeFluid, "Fluído de freio"),
            (record.changedSparkPlugs, "Velas de ignição")
        ].compactMap { $0.0 ? $0.1 : nil }
    }
}

struct OilChangeRegisterView: View {
    @State private var date = Date()
    @State private var kmText = ""
    @State private var intervalText = "5.000"
    @State private var nextDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @State private var didEditNextDate = false
    @State private var oilType = ""
    @State private var notes = ""
    @State private var draft: OilChangeDraft?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    Text("Registrar nova troca")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    DatePicker("Data da troca", selection: $date, displayedComponents: .date)
                        .onChange(of: date) { _, newDate in
                            if !didEditNextDate {
                                nextDate = Calendar.current.date(byAdding: .month, value: 6, to: newDate) ?? newDate
                            }
                        }

                    MaintenanceTextField(title: "Km atual do veículo", text: $kmText, keyboardType: .numberPad)
                        .onChange(of: kmText) { _, value in
                            kmText = OilChangeFormatting.kmField(OilChangeFormatting.parseKm(value))
                        }

                    Text("Próxima troca em")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    MaintenanceTextField(title: "Km para próxima troca", text: $intervalText, keyboardType: .numberPad)
                        .onChange(of: intervalText) { _, value in
                            intervalText = OilChangeFormatting.kmField(OilChangeFormatting.parseKm(value))
                        }

                    DatePicker("Data prevista", selection: $nextDate, displayedComponents: .date)
                        .onChange(of: nextDate) { _, _ in
                            didEditNextDate = true
                        }

                    MaintenanceTextField(title: "Tipo de óleo", placeholder: "Ex: 5W30 Sintético", text: $oilType)
                        .onChange(of: oilType) { _, value in
                            oilType = OilChangeFormatting.sanitized(value, maxLength: 50)
                        }

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Observações")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        TextEditor(text: $notes)
                            .frame(minHeight: 92)
                            .padding(8)
                            .background(AppTheme.Colors.background)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                                    .stroke(AppTheme.Colors.divider, lineWidth: 1)
                            }
                            .onChange(of: notes) { _, value in
                                notes = OilChangeFormatting.sanitized(value, maxLength: 120)
                            }

                        Text("\(notes.count)/120")
                            .font(.caption)
                            .foregroundStyle(AppTheme.Colors.textMuted)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    PrimaryButton(title: "Continuar") {
                        continueToItems()
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .navigationDestination(item: $draft) { draft in
            OilChangeItemsView(draft: draft)
        }
    }

    private func continueToItems() {
        let km = OilChangeFormatting.parseKm(kmText)
        guard km > 0 else {
            errorMessage = "Informe a quilometragem atual."
            return
        }

        let interval = max(OilChangeFormatting.parseKm(intervalText), 5_000)
        errorMessage = nil
        draft = OilChangeDraft(
            date: date,
            km: km,
            nextKm: km + interval,
            nextDate: nextDate,
            oilType: OilChangeFormatting.sanitized(oilType, maxLength: 50),
            notes: OilChangeFormatting.sanitized(notes, maxLength: 120)
        )
    }
}

extension OilChangeDraft: Identifiable {
    var id: String {
        "\(km)-\(date.timeIntervalSince1970)-\(nextKm)"
    }
}

private struct MaintenanceTextField: View {
    let title: String
    var placeholder = ""
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                        .stroke(AppTheme.Colors.divider, lineWidth: 1)
                }
        }
    }
}

struct OilChangeItemsView: View {
    @Environment(\.dismiss) private var dismiss
    let draft: OilChangeDraft

    @State private var changedEngineOil = true
    @State private var changedOilFilter = true
    @State private var changedAirFilter = false
    @State private var changedFuelFilter = false
    @State private var changedCabinFilter = false
    @State private var changedBrakeFluid = false
    @State private var changedSparkPlugs = false
    @State private var didSave = false

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    Text("Itens trocados")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("Selecione os itens que foram substituídos nesta troca.")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    Toggle("Óleo do motor", isOn: $changedEngineOil)
                    Toggle("Filtro de óleo", isOn: $changedOilFilter)
                    Toggle("Filtro de ar", isOn: $changedAirFilter)
                    Toggle("Filtro de combustível", isOn: $changedFuelFilter)
                    Toggle("Filtro de cabine", isOn: $changedCabinFilter)
                    Toggle("Fluído de freio", isOn: $changedBrakeFluid)
                    Toggle("Velas de ignição", isOn: $changedSparkPlugs)

                    HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(AppTheme.Colors.blue)

                        Text("Marque apenas os itens que foram realmente trocados.")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    PrimaryButton(title: "Salvar troca") {
                        save()
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .navigationDestination(isPresented: $didSave) {
            OilChangeConfirmationView()
        }
    }

    private func save() {
        OilChangeStore.save(
            OilChangeRecord(
                timestamp: 0,
                date: OilChangeFormatting.dateString(from: draft.date),
                km: draft.km,
                nextKm: draft.nextKm,
                nextDate: OilChangeFormatting.dateString(from: draft.nextDate),
                changedEngineOil: changedEngineOil,
                changedOilFilter: changedOilFilter,
                changedAirFilter: changedAirFilter,
                changedFuelFilter: changedFuelFilter,
                changedCabinFilter: changedCabinFilter,
                changedBrakeFluid: changedBrakeFluid,
                changedSparkPlugs: changedSparkPlugs,
                oilType: draft.oilType,
                notes: draft.notes
            )
        )
        didSave = true
    }
}

struct OilChangeConfirmationView: View {
    private var latestRecord: OilChangeRecord? {
        OilChangeStore.getLatest()
    }

    var body: some View {
        ScrollView {
            PageCard {
                VStack(spacing: AppTheme.Spacing.large) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(AppTheme.Colors.green)

                    Text("Troca registrada com sucesso!")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Sua manutenção está em dia.")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.textSecondary)

                    if let latestRecord {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                            MaintenanceValueRow(title: "Data da troca", value: latestRecord.date)
                            MaintenanceValueRow(title: "Km atual", value: OilChangeFormatting.kmText(latestRecord.km))
                            MaintenanceValueRow(
                                title: "Próxima troca",
                                value: "\(OilChangeFormatting.kmText(latestRecord.nextKm)) ou \(latestRecord.nextDate)"
                            )

                            let items = OilChangeFormatting.changedItems(for: latestRecord)
                            if !items.isEmpty {
                                Text("Itens trocados")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.Colors.textPrimary)

                                ForEach(items, id: \.self) { item in
                                    Text("✓ \(item)")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppTheme.Colors.green)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink {
                        OilChangeOverviewView()
                    } label: {
                        MaintenanceButtonLabel(title: "Voltar para resumo", style: .primary)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OilChangeHistoryView()
                    } label: {
                        MaintenanceButtonLabel(title: "Ver histórico", style: .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .navigationBarBackButtonHidden()
    }
}

private enum OilHistoryFilter: CaseIterable {
    case all
    case oil
    case filters

    var title: String {
        switch self {
        case .all: return "Todos"
        case .oil: return "Óleo"
        case .filters: return "Filtros"
        }
    }

    func matches(_ record: OilChangeRecord) -> Bool {
        switch self {
        case .all:
            return true
        case .oil:
            return record.changedEngineOil
        case .filters:
            return record.changedOilFilter || record.changedAirFilter || record.changedFuelFilter || record.changedCabinFilter
        }
    }
}

struct OilChangeHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [OilChangeRecord] = []
    @State private var selectedFilter: OilHistoryFilter = .all

    private var filteredHistory: [OilChangeRecord] {
        history.filter { selectedFilter.matches($0) }
    }

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    Text("Histórico de trocas")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    OilHistoryFilterPicker(selection: $selectedFilter)

                    if filteredHistory.isEmpty {
                        Text("Nenhuma troca registrada ainda.")
                            .font(.body)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.large)
                    } else {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            ForEach(filteredHistory) { record in
                                NavigationLink {
                                    OilChangeDetailView(timestamp: record.timestamp)
                                } label: {
                                    OilHistoryCard(record: record)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    NavigationLink {
                        OilChangeRegisterView()
                    } label: {
                        MaintenanceButtonLabel(title: "+ Nova troca", style: .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .frame(width: 54, height: 54)
                        .background(AppTheme.Colors.surface)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Voltar")

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.small)
            .padding(.bottom, AppTheme.Spacing.small)
        }
        .onAppear {
            history = OilChangeStore.getHistory()
        }
    }
}

private struct OilHistoryFilterPicker: View {
    @Binding var selection: OilHistoryFilter

    var body: some View {
        HStack(spacing: 0) {
            ForEach(OilHistoryFilter.allCases, id: \.self) { filter in
                Button {
                    selection = filter
                } label: {
                    Text(filter.title)
                        .font(.subheadline.weight(selection == filter ? .bold : .medium))
                        .foregroundStyle(selection == filter ? .white : AppTheme.Colors.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selection == filter ? AppTheme.Colors.blue : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
    }
}

private struct OilHistoryCard: View {
    let record: OilChangeRecord

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text("\(record.date) • \(OilChangeFormatting.kmText(record.km))")
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.textMuted)
                }

                Text("Próxima: \(OilChangeFormatting.kmText(record.nextKm)) ou \(record.nextDate)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)

                let items = OilChangeFormatting.changedItems(for: record)
                if !items.isEmpty {
                    Text(items.joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textMuted)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct OilChangeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let timestamp: Double
    @State private var record: OilChangeRecord?

    var body: some View {
        ScrollView {
            PageCard {
                if let record {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                        Text("Detalhes da troca")
                            .font(.title.bold())
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        MaintenanceValueRow(title: "Data da troca", value: record.date)
                        MaintenanceValueRow(title: "Km atual", value: OilChangeFormatting.kmText(record.km))
                        MaintenanceValueRow(
                            title: "Km para próxima troca",
                            value: "\(OilChangeFormatting.kmText(record.nextKm)) ou \(record.nextDate)"
                        )

                        if !record.notes.isEmpty {
                            MaintenanceValueRow(title: "Observações", value: record.notes)
                        }

                        if !record.oilType.isEmpty {
                            MaintenanceValueRow(title: "Tipo de óleo", value: record.oilType)
                        }

                        Divider()

                        Text("Itens trocados")
                            .font(.headline)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        ForEach(OilChangeFormatting.changedItems(for: record), id: \.self) { item in
                            Text("✓ \(item)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.Colors.green)
                        }

                        NavigationLink {
                            OilChangeEditView(timestamp: record.timestamp)
                        } label: {
                            MaintenanceButtonLabel(title: "Editar", style: .secondary)
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            OilChangeDeleteView(record: record) {
                                dismiss()
                            }
                        } label: {
                            Text("Excluir")
                                .font(.headline)
                                .foregroundStyle(Color(hex: 0xE53935))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(AppTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                                        .stroke(Color(hex: 0xE53935), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .onAppear {
            record = OilChangeStore.getHistory().first { $0.timestamp == timestamp }
            if record == nil {
                dismiss()
            }
        }
    }
}

struct OilChangeEditView: View {
    @Environment(\.dismiss) private var dismiss
    let timestamp: Double

    @State private var record: OilChangeRecord?
    @State private var date = Date()
    @State private var kmText = ""
    @State private var intervalText = "5.000"
    @State private var nextDate = Date()
    @State private var oilType = ""
    @State private var notes = ""
    @State private var changedEngineOil = false
    @State private var changedOilFilter = false
    @State private var changedAirFilter = false
    @State private var changedFuelFilter = false
    @State private var changedCabinFilter = false
    @State private var changedBrakeFluid = false
    @State private var changedSparkPlugs = false

    var body: some View {
        ScrollView {
            PageCard {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                    Text("Editar troca")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    DatePicker("Data da troca", selection: $date, displayedComponents: .date)
                    MaintenanceTextField(title: "Km atual", text: $kmText, keyboardType: .numberPad)
                    MaintenanceTextField(title: "Km para próxima", text: $intervalText, keyboardType: .numberPad)
                    DatePicker("Data prevista", selection: $nextDate, displayedComponents: .date)

                    if !oilType.isEmpty {
                        MaintenanceTextField(title: "Tipo de óleo", text: $oilType)
                    }

                    if !notes.isEmpty {
                        MaintenanceTextField(title: "Observações", text: $notes)
                    }

                    Toggle("Óleo do motor", isOn: $changedEngineOil)
                    Toggle("Filtro de óleo", isOn: $changedOilFilter)
                    Toggle("Filtro de ar", isOn: $changedAirFilter)
                    Toggle("Filtro de combustível", isOn: $changedFuelFilter)
                    Toggle("Filtro de cabine", isOn: $changedCabinFilter)
                    Toggle("Fluído de freio", isOn: $changedBrakeFluid)
                    Toggle("Velas de ignição", isOn: $changedSparkPlugs)

                    PrimaryButton(title: "Salvar alterações") {
                        save()
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
        .onAppear(perform: load)
        .onChange(of: kmText) { _, value in
            kmText = OilChangeFormatting.kmField(OilChangeFormatting.parseKm(value))
        }
        .onChange(of: intervalText) { _, value in
            intervalText = OilChangeFormatting.kmField(OilChangeFormatting.parseKm(value))
        }
    }

    private func load() {
        guard let record = OilChangeStore.getHistory().first(where: { $0.timestamp == timestamp }) else {
            dismiss()
            return
        }

        self.record = record
        date = OilChangeFormatting.date(from: record.date) ?? Date()
        kmText = OilChangeFormatting.kmField(record.km)
        intervalText = OilChangeFormatting.kmField(record.nextKm > record.km ? record.nextKm - record.km : 5_000)
        nextDate = OilChangeFormatting.date(from: record.nextDate) ?? Date()
        oilType = record.oilType
        notes = record.notes
        changedEngineOil = record.changedEngineOil
        changedOilFilter = record.changedOilFilter
        changedAirFilter = record.changedAirFilter
        changedFuelFilter = record.changedFuelFilter
        changedCabinFilter = record.changedCabinFilter
        changedBrakeFluid = record.changedBrakeFluid
        changedSparkPlugs = record.changedSparkPlugs
    }

    private func save() {
        guard let record else {
            return
        }

        let km = OilChangeFormatting.parseKm(kmText)
        let interval = max(OilChangeFormatting.parseKm(intervalText), 5_000)

        OilChangeStore.update(
            OilChangeRecord(
                timestamp: record.timestamp,
                date: OilChangeFormatting.dateString(from: date),
                km: km,
                nextKm: km + interval,
                nextDate: OilChangeFormatting.dateString(from: nextDate),
                changedEngineOil: changedEngineOil,
                changedOilFilter: changedOilFilter,
                changedAirFilter: changedAirFilter,
                changedFuelFilter: changedFuelFilter,
                changedCabinFilter: changedCabinFilter,
                changedBrakeFluid: changedBrakeFluid,
                changedSparkPlugs: changedSparkPlugs,
                oilType: OilChangeFormatting.sanitized(oilType, maxLength: 50),
                notes: OilChangeFormatting.sanitized(notes, maxLength: 120)
            )
        )
        dismiss()
    }
}

struct OilChangeDeleteView: View {
    @Environment(\.dismiss) private var dismiss
    let record: OilChangeRecord
    var onDelete: () -> Void = {}

    var body: some View {
        ScrollView {
            PageCard {
                VStack(spacing: AppTheme.Spacing.large) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.Colors.orange)

                    Text("Tem certeza que deseja excluir esta troca?")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        MaintenanceValueRow(title: "Data", value: record.date)
                        MaintenanceValueRow(title: "Km atual", value: OilChangeFormatting.kmText(record.km))
                    }
                    .padding(AppTheme.Spacing.medium)
                    .background(Color(hex: 0xF2F4F7))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))

                    Button {
                        OilChangeStore.delete(timestamp: record.timestamp)
                        onDelete()
                        dismiss()
                    } label: {
                        Text("Excluir troca")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: 0xE53935))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    SecondaryButton(title: "Cancelar") {
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, 120)
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    NavigationStack {
        MaintenanceView()
    }
}
